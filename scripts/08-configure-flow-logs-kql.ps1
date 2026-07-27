# ============================================================
# Lab 2 — Azure Networking
# Script 03: VNet Peering, NSGs, Storage Private Endpoint
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | July 2026
# ============================================================

# ── TASK 6: NSG FLOW LOGS AND LOG ANALYTICS ──────────────────────────────────

# Create Log Analytics Workspace
$LogAnalyticsWorkspace = New-AzOperationalInsightsWorkspace `
    -ResourceGroupName $ResourceGroup `
    -Name              "law-spoke-prod-eastus" `
    -Location          $Location `
    -Sku               "PerGB2018"

Write-Host "Log Analytics Workspace created: law-spoke-prod-eastus" -ForegroundColor Green

# Configure NSG Flow Logs via Network Watcher
$NsgApp = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroup -Name "nsg-spoke-app-eastus"
$Storage = Get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name "stproddataeastus"
$NetworkWatcher = Get-AzNetworkWatcher -ResourceGroupName "NetworkWatcherRG" -Name "NetworkWatcher_eastus"

New-AzNetworkWatcherFlowLog `
    -NetworkWatcher    $NetworkWatcher `
    -TargetResourceId  $NsgApp.Id `
    -StorageAccountId  $Storage.Id `
    -EnableRetention   $true `
    -RetentionInDays   30 `
    -Enabled           $true

Write-Host "NSG Flow Logs enabled with 30-day retention" -ForegroundColor Green
Write-Host "Note: AzureNetworkAnalytics_CL table populates after first 60-minute aggregation cycle" -ForegroundColor Yellow
$ResourceGroup = "rg-networking-prod-eastus"
$ResourceGroup = "rg-networking-prod-eastus"
