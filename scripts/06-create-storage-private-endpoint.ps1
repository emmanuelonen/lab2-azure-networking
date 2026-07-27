# ============================================================
# Lab 2 — Azure Networking
# Script 03: VNet Peering, NSGs, Storage Private Endpoint
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | July 2026
# ============================================================
# ── TASK 4: STORAGE ACCOUNT WITH PRIVATE ENDPOINT ───────────────────────────

# Create Storage Account — public access explicitly DISABLED
$StorageAccount = New-AzStorageAccount `
    -ResourceGroupName       $ResourceGroup `
    -Name                    "stproddataeastus" `
    -Location                $Location `
    -SkuName                 "Standard_LRS" `
    -Kind                    "StorageV2" `
    -PublicNetworkAccess     "Disabled" `
    -AllowBlobPublicAccess   $false

Write-Host "Storage account created with public access DISABLED" -ForegroundColor Green

# Get DataSubnet reference
$SpokeVNet        = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroup -Name "vnet-spoke-prod-eastus"
$DataSubnetId     = ($SpokeVNet.Subnets | Where-Object { $_.Name -eq "DataSubnet" }).Id

# Disable private endpoint network policy on DataSubnet (required before creating private endpoint)
($SpokeVNet.Subnets | Where-Object { $_.Name -eq "DataSubnet" }).PrivateEndpointNetworkPolicies = "Disabled"
$SpokeVNet | Set-AzVirtualNetwork

# Create Private Endpoint in DataSubnet
$PrivateLinkServiceConnection = New-AzPrivateLinkServiceConnection `
    -Name                  "pe-connection-blob" `
    -PrivateLinkServiceId  $StorageAccount.Id `
    -GroupId               "blob"

$PrivateEndpoint = New-AzPrivateEndpoint `
    -ResourceGroupName     $ResourceGroup `
    -Name                  "pe-storage-blob-prod" `
    -Location              $Location `
    -Subnet                ($SpokeVNet.Subnets | Where-Object { $_.Name -eq "DataSubnet" }) `
    -PrivateLinkServiceConnection $PrivateLinkServiceConnection

Write-Host "Private Endpoint pe-storage-blob-prod created in DataSubnet" -ForegroundColor Green

# Create Private DNS Zone and link to Spoke VNet
$PrivateDnsZone = New-AzPrivateDnsZone `
    -ResourceGroupName $ResourceGroup `
    -Name              "privatelink.blob.core.windows.net"

$DnsVNetLink = New-AzPrivateDnsVirtualNetworkLink `
    -ResourceGroupName  $ResourceGroup `
    -ZoneName           "privatelink.blob.core.windows.net" `
    -Name               "dns-link-spoke" `
    -VirtualNetworkId   $SpokeVNet.Id `
    -EnableRegistration $false

# Create DNS zone group — auto-registers private endpoint IP in DNS zone
$PrivateDnsZoneGroup = New-AzPrivateDnsZoneGroup `
    -ResourceGroupName          $ResourceGroup `
    -PrivateEndpointName        "pe-storage-blob-prod" `
    -Name                       "storage-dns-zone-group" `
    -PrivateDnsZoneId           $PrivateDnsZone.ResourceId

Write-Host "Private DNS Zone configured — FQDN will resolve to 10.1.2.4 internally" -ForegroundColor Green
