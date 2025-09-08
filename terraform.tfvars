#########################################################################################
############################ MyBrand Combined Environment Variables ##################
#########################################################################################

# Default environment variables (set for DEV by default)
AWS_Region      = "ap-southeast-2"
AWS_AccountName = "AWS-MyBrand-DEV"
AWS_AccountID   = "XXXXXXXXXXXX"
AWS_Environment = "DEV"

AWS_Tags = {
  Owner              = "MyBrand"
  Project            = "MyBrand-Network"
  Designation        = "DEV"
  Team               = "MyBrand"
  StakeHolder        = "MyBrand"
  CostCenter         = "TBA"
  Backup             = "False"
  "Cost Label"       = "Apps Support"
  TerraformProject   = "AWS-MyBrand"
  TerraformWorkspace = "MyBrand-Network-DEV"
  DataSensitivity    = "INT"
}

Project_Name = "MyBrand-Network"

VPC_CidrBlock        = "10.10.1.0/24"
Public_Subnet_Count  = 1
Private_Subnet_Count = 3
Subnet_Prefix        = 27

Transit_Gateway_ID = "tgw-xxxxxxxxxxxxxxxxx"

Igw = false
Nat = false

Use_Transit_Gateway_For_Default_Route = true

#########################################################################################
# To switch to STG or PRD, override the above variables in CLI or workspace
#########################################################################################

# Example for STG:
# AWS_Region      = "ap-southeast-2"
# AWS_AccountName = "AWS-MyBrand-STG"
# AWS_AccountID   = "XXXXXXXXXXXX"
# AWS_Environment = "STG"
# AWS_Tags = {
#   Owner              = "MyBrand"
#   Project            = "MyBrand-Network"
#   Designation        = "STG"
#   Team               = "MyBrand"
#   StakeHolder        = "MyBrand"
#   CostCenter         = "TBA"
#   Backup             = "False"
#   "Cost Label"       = "Apps Support"
#   TerraformProject   = "AWS-MyBrand"
#   TerraformWorkspace = "MyBrand-Network-STG"
#   DataSensitivity    = "INT"
# }
# Project_Name = "MyBrand-Network"
# VPC_CidrBlock        = "10.0.0.0/24"
# Public_Subnet_Count  = 1
# Private_Subnet_Count = 3
# Subnet_Prefix        = 27
# Transit_Gateway_ID = "tgw-xxxxxxxxxxxxxxxxx"
# Use_Transit_Gateway_For_Default_Route = true

# Example for PRD:
# AWS_Region      = "ap-southeast-2"
# AWS_AccountName = "AWS-MyBrand-PRD"
# AWS_AccountID   = "XXXXXXXXXXXX"
# AWS_Environment = "PRD"
# AWS_Tags = {
#   Owner              = "MyBrand"
#   Project            = "MyBrand-Network"
#   Designation        = "PRD"
#   Team               = "MyBrand"
#   StakeHolder        = "MyBrand"
#   CostCenter         = "TBA"
#   Backup             = "False"
#   "Cost Label"       = "Apps Support"
#   TerraformProject   = "AWS-MyBrand"
#   TerraformWorkspace = "MyBrand-Network-PRD"
#   DataSensitivity    = "INT"
# }
# Project_Name = "MyBrand-Network"
# VPC_CidrBlock        = "10.0.0.0/24"
# Public_Subnet_Count  = 1
# Private_Subnet_Count = 3
# Subnet_Prefix        = 27
# Transit_Gateway_ID = "tgw-xxxxxxxxxxxxxxxxx"
# Use_Transit_Gateway_For_Default_Route = true
