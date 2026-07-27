# ============================================================
# Lab 2 — Azure Networking
# Script 02: Create Hub and Spoke VNets with Subnets
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | July 2026
# ============================================================

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
