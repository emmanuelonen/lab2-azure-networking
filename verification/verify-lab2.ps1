# ============================================================
# Lab 2 — Azure Networking
# Verification Script — Confirm All Lab Resources and Connectivity
# Emmanuel Onen | Senior Systems Engineer | Cayman Islands | July 2026
# ============================================================
# Run this after completing all lab steps.
# Every check should return the expected result listed in the comments.
# If any check fails, refer to the troubleshooting section in README.md
# ============================================================

-ForegroundColor Cyan
Write-Host "If all checks passed — Lab 2 is complete and all resources are verified.`n" -ForegroundColor Green
Write-Host "DNS resolution test (run from vm-app-test via Bastion):" -ForegroundColor Yellow
Write-Host "  nslookup stproddataeastus.blob.core.windows.net" -ForegroundColor White
Write-Host "  Expected result: Non-authoritative answer — Address: 10.1.2.4`n" -ForegroundColor White
