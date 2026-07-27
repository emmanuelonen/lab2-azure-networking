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
