# ── SPOKE VNET ───────────────────────────────────────────────────────────────

# Define Spoke subnets
$AppSubnet  = New-AzVirtualNetworkSubnetConfig `
    -Name "AppSubnet" `
    -AddressPrefix "10.1.1.0/24"

$DataSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name "DataSubnet" `
    -AddressPrefix "10.1.2.0/24"

# Create Spoke VNet
$SpokeVNet = New-AzVirtualNetwork `
    -ResourceGroupName $ResourceGroup `
    -Location          $Location `
    -Name              "vnet-spoke-prod-eastus" `
    -AddressPrefix     "10.1.0.0/16" `
    -Subnet            $AppSubnet, $DataSubnet

Write-Host "Spoke VNet created: vnet-spoke-prod-eastus (10.1.0.0/16)" -ForegroundColor Green


# ── VERIFY ───────────────────────────────────────────────────────────────────
Get-AzVirtualNetwork -ResourceGroupName $ResourceGroup |
    Select-Object Name, Location, @{N='AddressSpace';E={$_.AddressSpace.AddressPrefixes}}
