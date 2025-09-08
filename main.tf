#########################################################################################
######################## MyBrand VPC, Gateways, Routing, Monitoring ##################
#########################################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data sources for AWS account and region information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Dynamic VPC name using environment
  vpc_name = "MyBrand-vpc-${lower(var.AWS_Environment)}"

  # Use only the first N availability zones based on subnet count
  azs = slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), var.Private_Subnet_Count))

  # Calculate subnet CIDR blocks
  newbits      = var.Subnet_Prefix - tonumber(split("/", var.VPC_CidrBlock)[1])
  subnet_cidrs = [for i in range(var.Private_Subnet_Count) : cidrsubnet(var.VPC_CidrBlock, local.newbits, i)]

  # Public subnet CIDR is the next available block after private subnets
  public_subnet_cidr = cidrsubnet(var.VPC_CidrBlock, local.newbits, var.Private_Subnet_Count)

  # Common tags from AWS_Tags variable
  common_tags = var.AWS_Tags
}

#########################################################################################
################################## VPC Resources ######################################
#########################################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.VPC_CidrBlock
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = local.vpc_name
  })
}

#########################################################################################
################################## Subnet Resources #####################################
#########################################################################################

# Private subnets for application resources
resource "aws_subnet" "private" {
  count = var.Private_Subnet_Count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet_cidrs[count.index]
  availability_zone       = local.azs[count.index % length(local.azs)]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-private-subnet-${local.azs[count.index % length(local.azs)]}"
    Type = "Private"
  })
}

# Public subnet for internet-facing resources (in AZ-a)
resource "aws_subnet" "public" {
  count = var.Public_Subnet_Count

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-public-subnet-${data.aws_availability_zones.available.names[0]}"
    Type = "Public"
  })
}

#########################################################################################
############################ Transit Gateway Attachment ###############################
#########################################################################################

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  transit_gateway_id = var.Transit_Gateway_ID
  vpc_id             = aws_vpc.main.id
  subnet_ids         = aws_subnet.private[*].id

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-tgw-attachment"
  })
}

#########################################################################################
############################ Internet Gateway Attachment ###############################
#########################################################################################

resource "aws_internet_gateway" "gw" {
  count = var.Igw ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-igw-attachment"
  })
}

#########################################################################################
############################ NAT Gateway Attachment ####################################
#########################################################################################

resource "aws_eip" "nat" {
  count = var.Nat ? var.Public_Subnet_Count : 0

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-nat-eip"
  })
}

resource "aws_nat_gateway" "nat" {
  count = var.Nat ? var.Public_Subnet_Count : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-nat-gateway"
  })
}

#########################################################################################
################################ Route Table Resources ################################
#########################################################################################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-private-rt"
    Type = "Private"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-public-rt"
    Type = "Public"
  })
}

#########################################################################################
################################## Route Resources ####################################
#########################################################################################

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = var.Gateway_Dependencies.transit_gateway_id
}

#########################################################################################
############################ Route Table Associations #################################
#########################################################################################

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private[*].id)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#########################################################################################
################################## VPC Flow Logs ######################################
#########################################################################################

resource "aws_iam_role" "vpc_flow_logs" {
  name = "${local.vpc_name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-vpc-flow-logs-role"
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${local.vpc_name}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs/${local.vpc_name}"
  retention_in_days = var.Flow_Log_Retention_Days

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-flow-logs"
  })
}

resource "aws_flow_log" "vpc" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-flow-logs"
  })
}
