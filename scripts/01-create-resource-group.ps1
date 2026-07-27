# ============================================================
# Lab 2 — Azure Networking
# Script 01: Create Resource Group
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | July 2026
# ============================================================
# Naming convention: rg-<workload>-<environment>-<region>
# This follows Enterprise Azure Landing Zone naming standards.
# All Lab 2 resources are contained in this single resource group
# for clean lifecycle management — delete the group to remove all resources.
# ============================================================

# Connect to Azure (run once per session)
Connect-AzAccount

# Set variables — adjust subscription and region as needed
$ResourceGroupName = "rg-networking-prod-eastus"
$Location          = "EastUS"

# Create the resource group
New-AzResourceGroup `
    -Name     $ResourceGroupName `
    -Location $Location

# Verify creation
Get-AzResourceGroup -Name $ResourceGroupName | Select-Object ResourceGroupName, Location, ProvisioningState

Write-Host "Resource group '$ResourceGroupName' created in '$Location'" -ForegroundColor Green
# ADDRESS SPACE DESIGN:
#   Hub VNet:   10.0.0.0/16  — shared services, gateway, management
#     GatewaySubnet:      10.0.1.0/24  — RESERVED: VPN/ExpressRoute only
#     ManagementSubnet:   10.0.2.0/24  — admin/jumpbox traffic
#
#   Spoke VNet: 10.1.0.0/16  — workload isolation
#     AppSubnet:  10.1.1.0/24  — application tier (vm-app-test)
#     DataSubnet: 10.1.2.0/24  — data tier (Private Endpoint at 10.1.2.4)
#
# IMPORTANT: GatewaySubnet is case-sensitive and must be spelled exactly.
# Azure requires this name for any subnet hosting a VPN or ExpressRoute Gateway.
# No other resources should be placed in GatewaySubnet.
# ============================================================

$ResourceGroup = "rg-networking-prod-eastus"
$Location      = "EastUS"
