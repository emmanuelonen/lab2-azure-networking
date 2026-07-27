# ============================================================
# Lab 2 — Azure Networking
# Script 03: VNet Peering, NSGs, Storage Private Endpoint
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | July 2026
# ============================================================

# ── TASK 5: DEPLOY TEST VM IN APPSUBNET (NO PUBLIC IP) ───────────────────────

$VMCredential = Get-Credential -Message "Set local admin credentials for vm-app-test"

$NIC = New-AzNetworkInterface `
    -ResourceGroupName $ResourceGroup `
    -Name              "nic-vm-app-test" `
    -Location          $Location `
    -SubnetId          ($SpokeVNet.Subnets | Where-Object { $_.Name -eq "AppSubnet" }).Id

$VMConfig = New-AzVMConfig -VMName "vm-app-test" -VMSize "Standard_B1s" |
    Set-AzVMOperatingSystem -Windows -ComputerName "vm-app-test" -Credential $VMCredential |
    Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-Datacenter" -Version "latest" |
    Add-AzVMNetworkInterface -Id $NIC.Id

New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VMConfig

Write-Host "Test VM vm-app-test deployed in AppSubnet — No public IP assigned" -ForegroundColor Green
Write-Host "Access via Azure Bastion or internal jumpbox only" -ForegroundColor Yellow
