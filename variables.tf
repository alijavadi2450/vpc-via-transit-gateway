#########################################################################################
############################ MyBrand Combined Variables ##############################
#########################################################################################

# AWS Variables
variable "AWS_Region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "AWS_Environment" {
  description = "Environment name (e.g., DEV, STG, PRD)"
  type        = string
  validation {
    condition     = contains(["DEV", "STG", "PRD"], var.AWS_Environment)
    error_message = "AWS_Environment must be one of: DEV, STG, PRD."
  }
}

variable "AWS_AccountID" {
  description = "AWS Account ID"
  type        = string
}

variable "AWS_AccountName" {
  description = "AWS Account Name for tagging and identification"
  type        = string
}

variable "Project_Name" {
  description = "Project name for tagging and identification"
  type        = string
}

variable "AWS_Tags" {
  description = "Common tags for all MyBrand VPC resources"
  type        = map(string)
  default     = {}
}

# VPC Core Variables
variable "VPC_CidrBlock" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "Private_Subnet_Count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 3
  validation {
    condition     = var.Private_Subnet_Count >= 2 && var.Private_Subnet_Count <= 6
    error_message = "Private subnet count must be between 2 and 6."
  }
}

variable "Public_Subnet_Count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 1
}

variable "Subnet_Prefix" {
  description = "Prefix length (mask) for subnets, e.g. 28 for /28"
  type        = number
  default     = 28
  validation {
    condition     = var.Subnet_Prefix >= 16 && var.Subnet_Prefix <= 28
    error_message = "Subnet prefix must be between 16 and 28."
  }
}

# Gateway Variables
variable "VPC_ID" {
  description = "VPC ID where gateways will be created"
  type        = string
}

variable "Private_Subnet_IDs" {
  description = "Private subnet IDs for Transit Gateway attachment and routing"
  type        = list(string)
}

variable "Transit_Gateway_ID" {
  description = "Transit Gateway ID for VPC attachment"
  type        = string
}

variable "Igw" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = false
}

variable "Nat" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = false
}

# Routing Variables
variable "Public_Subnet_IDs" {
  description = "Public subnet IDs for route table association"
  type        = list(string)
}

variable "Gateway_Dependencies" {
  description = "Gateway dependencies from the gateways module"
  type = object({
    internet_gateway_id = string
    nat_gateway_id      = string
    transit_gateway_id  = string
  })
}

variable "Use_Transit_Gateway_For_Default_Route" {
  description = "Use Transit Gateway for default route instead of NAT Gateway"
  type        = bool
  default     = false
}

# Monitoring Variables
variable "Flow_Log_Retention_Days" {
  description = "Retention period for VPC Flow Logs in days"
  type        = number
  default     = 30
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.Flow_Log_Retention_Days)
    error_message = "Flow_Log_Retention_Days must be a valid CloudWatch log retention period."
  }
}
