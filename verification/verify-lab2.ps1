=== LAB 2 VERIFICATION — AZURE NETWORKING ===" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroup`n"

# CHECK 1 — Hub VNet exists with correct subnets
Write-Host "CHECK 1: Hub VNet" -ForegroundColor Yellow
Get-AzVirtualNetwork -ResourceGroupName $ResourceGroup -Name "vnet-hub-prod-eastus" |
    Select-Object Name, Location, @{N='AddressSpace';E={$_.AddressSpace.AddressPrefixes}}, @{N='Subnets';E={$_.Subnets.Name}}
# Expected: vnet-hub-prod-eastus | 10.0.0.0/16 | GatewaySubnet, ManagementSubnet

# CHECK 2 — Spoke VNet exists with correct subnets
Write-Host "`nCHECK 2: Spoke VNet" -ForegroundColor Yellow
Get-AzVirtualNetwork -ResourceGroupName $ResourceGroup -Name "vnet-spoke-prod-eastus" |
    Select-Object Name, Location, @{N='AddressSpace';E={$_.AddressSpace.AddressPrefixes}}, @{N='Subnets';E={$_.Subnets.Name}}
# Expected: vnet-spoke-prod-eastus | 10.1.0.0/16 | AppSubnet, DataSubnet

# CHECK 3 — VNet Peering status
Write-Host "`nCHECK 3: VNet Peering" -ForegroundColor Yellow
Get-AzVirtualNetworkPeering -ResourceGroupName $ResourceGroup -VirtualNetworkName "vnet-hub-prod-eastus" |
    Select-Object Name, PeeringState, PeeringSyncLevel
# Expected: hub-to-spoke | Connected | FullySynced

# CHECK 4 — NSGs associated with subnets
Write-Host "`nCHECK 4: NSG associations" -ForegroundColor Yellow
$SpokeVNet = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroup -Name "vnet-spoke-prod-eastus"
$SpokeVNet.Subnets | Select-Object Name, @{N='NSG';E={$_.NetworkSecurityGroup.Id.Split('/')[-1]}}
# Expected: AppSubnet → nsg-spoke-app-eastus | DataSubnet → nsg-data-prod

# CHECK 5 — Storage account public access disabled
Write-Host "`nCHECK 5: Storage account public access" -ForegroundColor Yellow
Get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name "stproddataeastus" |
    Select-Object StorageAccountName, PublicNetworkAccess, AllowBlobPublicAccess
# Expected: stproddataeastus | Disabled | False

# CHECK 6 — Private endpoint provisioned
Write-Host "`nCHECK 6: Private Endpoint" -ForegroundColor Yellow
Get-AzPrivateEndpoint -ResourceGroupName $ResourceGroup -Name "pe-storage-blob-prod" |
    Select-Object Name, ProvisioningState, @{N='Subnet';E={$_.Subnet.Id.Split('/')[-1]}}
# Expected: pe-storage-blob-prod | Succeeded | DataSubnet

# CHECK 7 — Private DNS Zone exists and linked
Write-Host "`nCHECK 7: Private DNS Zone" -ForegroundColor Yellow
Get-AzPrivateDnsZone -ResourceGroupName $ResourceGroup -Name "privatelink.blob.core.windows.net" |
    Select-Object Name, NumberOfRecordSets
# Expected: privatelink.blob.core.windows.net | 2+ (SOA + A record for private endpoint)

# CHECK 8 — Flow Logs enabled
Write-Host "`nCHECK 8: NSG Flow Logs" -ForegroundColor Yellow
$NetworkWatcher = Get-AzNetworkWatcher -ResourceGroupName "NetworkWatcherRG" -Name "NetworkWatcher_eastus"
$NsgApp = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroup -Name "nsg-spoke-app-eastus"
Get-AzNetworkWatcherFlowLog -NetworkWatcher $NetworkWatcher -TargetResourceId $NsgApp.Id |
    Select-Object Enabled, RetentionPolicyDays, StorageId
# Expected: Enabled=True | RetentionPolicyDays=30

Write-Host "`n=== VERIFICATION COMPLETE ===" -ForegroundColor Cyan
Write-Host "If all checks passed — Lab 2 is complete and all resources are verified.`n" -ForegroundColor Green
Write-Host "DNS resolution test (run from vm-app-test via Bastion):" -ForegroundColor Yellow
Write-Host "  nslookup stproddataeastus.blob.core.windows.net" -ForegroundColor White
Write-Host "  Expected result: Non-authoritative answer — Address: 10.1.2.4`n" -ForegroundColor White
