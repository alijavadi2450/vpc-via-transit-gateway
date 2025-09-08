# Azure VNet via ExpressRoute Deployment (Terraform - Using Existing Variables)

## Overview

This guide explains how to deploy a **Virtual Network (VNet)** in Azure and connect it to on-premises or other cloud environments using **Azure ExpressRoute** with **Terraform**, reusing the same variable naming convention as our AWS TGW deployment (`terraform.tfvars`).  
Even though the variable names may contain `AWS` in them, they can be repurposed for Azure to maintain consistency across multi-cloud deployments.

---

## Why Use Azure ExpressRoute?

Azure ExpressRoute enables you to extend your on-premises networks into the Microsoft cloud over a private connection facilitated by a connectivity provider.

### Benefits:
- **Private Connectivity**: Traffic does not traverse the public internet.
- **Enhanced Security**: Private circuits ensure data confidentiality and integrity.
- **High Reliability**: SLA-backed connectivity with predictable performance.
- **Scalability**: Supports high bandwidth for large-scale workloads.
- **Hybrid Cloud Enablement**: Seamlessly integrate on-premises infrastructure with Azure services.

---

## Terraform Configuration Example (Using Existing Variables)

```hcl
provider "azurerm" {
  features {}
}

# Variables reused from terraform.tfvars
variable "AWS_Environment" {}
variable "AWS_Tags" {
  type = map(string)
}
variable "VPC_CidrBlock" {}
variable "Private_Subnet_Count" {}
variable "Public_Subnet_Count" {}
variable "Transit_Gateway_ID" {} # Will be used as ExpressRoute Circuit ID or placeholder
variable "Igw" {}
variable "Nat" {}
variable "Flow_Log_Retention_Days" {}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.AWS_Environment}-rg"
  location = "eastus"
  tags     = var.AWS_Tags
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.AWS_Environment}-vnet"
  address_space       = [var.VPC_CidrBlock]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.AWS_Tags
}

# Subnets
resource "azurerm_subnet" "private" {
  count                = var.Private_Subnet_Count
  name                 = "${var.AWS_Environment}-private-${count.index}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.VPC_CidrBlock, 8, count.index)]
}

resource "azurerm_subnet" "public" {
  count                = var.Public_Subnet_Count
  name                 = "${var.AWS_Environment}-public-${count.index}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.VPC_CidrBlock, 8, count.index + var.Private_Subnet_Count)]
}

# ExpressRoute Circuit
resource "azurerm_express_route_circuit" "erc" {
  name                  = "${var.AWS_Environment}-expressroute"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_provider_name = "MyProvider"
  peering_location      = "Seattle"
  bandwidth_in_mbps     = 200

  sku {
    tier   = "Standard"
    family = "MeteredData"
  }

  tags = var.AWS_Tags
}

# Public IP for Gateway
resource "azurerm_public_ip" "gateway_ip" {
  name                = "${var.AWS_Environment}-gateway-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  tags                = var.AWS_Tags
}

# Virtual Network Gateway
resource "azurerm_virtual_network_gateway" "vng" {
  name                = "${var.AWS_Environment}-vnet-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  type                = "ExpressRoute"
  vpn_type            = "RouteBased"
  sku                 = "Standard"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.gateway_ip.id
    subnet_id                     = azurerm_subnet.private[0].id
  }

  tags = var.AWS_Tags
}

# ExpressRoute Connection
resource "azurerm_virtual_network_gateway_connection" "er_connection" {
  name                = "${var.AWS_Environment}-er-connection"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vng.id
  express_route_circuit_id   = azurerm_express_route_circuit.erc.id

  tags = var.AWS_Tags
}
```

---

## Deployment Steps

1. Ensure your `terraform.tfvars` contains the required variables (even if AWS-named).
2. Run:
```bash
terraform init
terraform plan
terraform apply
```
3. Verify in Azure Portal:
   - VNet and subnets
   - ExpressRoute circuit
   - Virtual Network Gateway
   - Connection status

4. To destroy:
```bash
terraform destroy
```

---

## Notes
- This approach reuses the same variable names as AWS TGW deployment for consistency.
- The `Transit_Gateway_ID` variable can be repurposed for ExpressRoute circuit references or left unused.
- CIDR calculations reuse the same logic as AWS subnets for parity.
