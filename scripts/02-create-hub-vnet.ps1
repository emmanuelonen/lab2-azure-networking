# ============================================================
# Lab 2 — Azure Networking
# Script 02: Create Hub and Spoke VNets with Subnets
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | July 2026
# ============================================================
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

# ── HUB VNET ─────────────────────────────────────────────────────────────────

# Define Hub subnets
$GatewaySubnet    = New-AzVirtualNetworkSubnetConfig `
    -Name "GatewaySubnet" `
    -AddressPrefix "10.0.1.0/24"

$ManagementSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name "ManagementSubnet" `
    -AddressPrefix "10.0.2.0/24"

# Create Hub VNet
$HubVNet = New-AzVirtualNetwork `
    -ResourceGroupName $ResourceGroup `
    -Location          $Location `
    -Name              "vnet-hub-prod-eastus" `
    -AddressPrefix     "10.0.0.0/16" `
    -Subnet            $GatewaySubnet, $ManagementSubnet

Write-Host "Hub VNet created: vnet-hub-prod-eastus (10.0.0.0/16)" -ForegroundColor Green
