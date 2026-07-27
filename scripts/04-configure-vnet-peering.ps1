# ============================================================
# Lab 2 — Azure Networking
# Script 03: VNet Peering, NSGs, Storage Private Endpoint
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | July 2026
# ============================================================

$ResourceGroup = "rg-networking-prod-eastus"
$Location      = "EastUS"

# Get VNet references
$HubVNet   = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroup -Name "vnet-hub-prod-eastus"
$SpokeVNet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroup -Name "vnet-spoke-prod-eastus"


# ── TASK 2: VNET PEERING ─────────────────────────────────────────────────────
# Peering must be configured in BOTH directions.
# Both sides must show Connected status before traffic flows.

# Hub → Spoke
Add-AzVirtualNetworkPeering `
    -Name                   "hub-to-spoke" `
    -VirtualNetwork         $HubVNet `
    -RemoteVirtualNetworkId $SpokeVNet.Id `
    -AllowVirtualNetworkAccess

# Spoke → Hub
Add-AzVirtualNetworkPeering `
    -Name                   "spoke-to-hub" `
    -VirtualNetwork         $SpokeVNet `
    -RemoteVirtualNetworkId $HubVNet.Id `
    -AllowVirtualNetworkAccess

Write-Host "VNet Peering configured bidirectionally" -ForegroundColor Green

# Verify peering — both must show Connected
Get-AzVirtualNetworkPeering -ResourceGroupName $ResourceGroup -VirtualNetworkName "vnet-hub-prod-eastus" |
    Select-Object Name, PeeringState, PeeringSyncLevel
