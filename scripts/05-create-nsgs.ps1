# ── TASK 3: NETWORK SECURITY GROUPS ─────────────────────────────────────────
# NSG for AppSubnet — least privilege ingress
# Priority 100: Allow HTTP/HTTPS from VirtualNetwork tag
# Priority 65500: DenyAllInbound (platform default — explicit here for clarity)

$AllowWebInbound = New-AzNetworkSecurityRuleConfig `
    -Name                     "Allow-VNet-Inbound-80-443" `
    -Priority                 100 `
    -Direction                Inbound `
    -Access                   Allow `
    -Protocol                 Tcp `
    -SourceAddressPrefix      "VirtualNetwork" `
    -SourcePortRange          "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange     "80","443"

$AllowMgmtRDP = New-AzNetworkSecurityRuleConfig `
    -Name                     "Allow-Management-RDP" `
    -Priority                 110 `
    -Direction                Inbound `
    -Access                   Allow `
    -Protocol                 Tcp `
    -SourceAddressPrefix      "10.0.2.0/24" `
    -SourcePortRange          "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange     "3389"

$NsgApp = New-AzNetworkSecurityGroup `
    -ResourceGroupName $ResourceGroup `
    -Location          $Location `
    -Name              "nsg-spoke-app-eastus" `
    -SecurityRules     $AllowWebInbound, $AllowMgmtRDP

Write-Host "NSG nsg-spoke-app-eastus created with least-privilege rules" -ForegroundColor Green

# NSG for DataSubnet — restrict to AppSubnet source only
$AllowAppToData = New-AzNetworkSecurityRuleConfig `
    -Name                     "Allow-AppSubnet-HTTPS" `
    -Priority                 100 `
    -Direction                Inbound `
    -Access                   Allow `
    -Protocol                 Tcp `
    -SourceAddressPrefix      "10.1.1.0/24" `
    -SourcePortRange          "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange     "443"

$DenyAllData = New-AzNetworkSecurityRuleConfig `
    -Name                     "Deny-All-Other-Inbound" `
    -Priority                 4000 `
    -Direction                Inbound `
    -Access                   Deny `
    -Protocol                 "*" `
    -SourceAddressPrefix      "*" `
    -SourcePortRange          "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange     "*"

$NsgData = New-AzNetworkSecurityGroup `
    -ResourceGroupName $ResourceGroup `
    -Location          $Location `
    -Name              "nsg-data-prod" `
    -SecurityRules     $AllowAppToData, $DenyAllData

Write-Host "NSG nsg-data-prod created — AppSubnet source restriction applied" -ForegroundColor Green

# Associate NSGs with subnets
$SpokeVNet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroup -Name "vnet-spoke-prod-eastus"

$AppSubnetConfig  = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $SpokeVNet -Name "AppSubnet"
$DataSubnetConfig = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $SpokeVNet -Name "DataSubnet"

Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $SpokeVNet -Name "AppSubnet" `
    -AddressPrefix $AppSubnetConfig.AddressPrefix `
    -NetworkSecurityGroup $NsgApp | Set-AzVirtualNetwork

Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $SpokeVNet -Name "DataSubnet" `
    -AddressPrefix $DataSubnetConfig.AddressPrefix `
    -NetworkSecurityGroup $NsgData | Set-AzVirtualNetwork

Write-Host "NSGs associated with AppSubnet and DataSubnet" -ForegroundColor Green
