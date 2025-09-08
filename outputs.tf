#########################################################################################
############################ MyBrand Combined Outputs ################################
#########################################################################################

# VPC Outputs
output "VPC_ID" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "VPC_CIDR_Block" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "VPC_ARN" {
  description = "VPC ARN"
  value       = aws_vpc.main.arn
}

output "Private_Subnet_IDs" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "Private_Subnet_CIDRs" {
  description = "Private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "Public_Subnet_IDs" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "Public_Subnet_ID" {
  description = "Public subnet ID"
  value       = aws_subnet.public[0].id
}

output "Public_Subnet_CIDR" {
  description = "Public subnet CIDR block"
  value       = aws_subnet.public[0].cidr_block
}

output "Availability_Zones" {
  description = "Availability zones used"
  value       = local.azs
}

output "VPC_Resources" {
  description = "VPC resource information"
  value = {
    vpc_id               = aws_vpc.main.id
    vpc_arn              = aws_vpc.main.arn
    vpc_cidr_block       = aws_vpc.main.cidr_block
    private_subnet_ids   = aws_subnet.private[*].id
    public_subnet_id     = aws_subnet.public[0].id
    private_subnet_cidrs = aws_subnet.private[*].cidr_block
    public_subnet_cidr   = aws_subnet.public[0].cidr_block
    availability_zones   = local.azs
  }
}

# Gateway Outputs
output "Transit_Gateway_Attachment_ID" {
  description = "Transit Gateway VPC Attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.main.id
}

output "Gateway_Dependencies" {
  description = "Gateway dependencies for routing module"
  value = {
    internet_gateway_id = aws_internet_gateway.gw[0].id
    nat_gateway_id      = ""
    transit_gateway_id  = var.Transit_Gateway_ID
  }
}

# Routing Outputs
output "Private_Route_Table_ID" {
  description = "Private Route Table ID"
  value       = aws_route_table.private.id
}

output "Private_Route_Table_Association_IDs" {
  description = "Private Route Table Association IDs"
  value       = aws_route_table_association.private[*].id
}

output "Route_Tables" {
  description = "Route table information"
  value = {
    private_route_table_id = aws_route_table.private.id
  }
}

# Monitoring Outputs
output "VPC_Flow_Log_ID" {
  description = "VPC Flow Log ID"
  value       = aws_flow_log.vpc.id
}

output "VPC_Flow_Log_CloudWatch_Log_Group_Name" {
  description = "CloudWatch Log Group name for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

output "VPC_Flow_Log_CloudWatch_Log_Group_ARN" {
  description = "CloudWatch Log Group ARN for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.arn
}

output "VPC_Flow_Log_IAM_Role_ARN" {
  description = "IAM Role ARN for VPC Flow Logs"
  value       = aws_iam_role.vpc_flow_logs.arn
}

output "VPC_Flow_Log_IAM_Role_Name" {
  description = "IAM Role name for VPC Flow Logs"
  value       = aws_iam_role.vpc_flow_logs.name
}

output "Monitoring_Resources" {
  description = "Monitoring resource information"
  value = {
    flow_log_id               = aws_flow_log.vpc.id
    cloudwatch_log_group_name = aws_cloudwatch_log_group.vpc_flow_logs.name
    cloudwatch_log_group_arn  = aws_cloudwatch_log_group.vpc_flow_logs.arn
    iam_role_arn              = aws_iam_role.vpc_flow_logs.arn
  }
}
