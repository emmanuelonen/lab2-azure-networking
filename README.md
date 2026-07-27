# Lab 2 — Azure Networking
### Secure Hub-and-Spoke Network Architecture · Private Endpoints · NSG Micro-Segmentation

| Field | Value |
|---|---|
| **Completed** | 27 July 2026 |
| **Platform** | Microsoft Azure Portal · Azure PowerShell · Azure CLI |
| **Cost** | $0 — Azure Free Account (750hrs VPN Gateway, 5 free NSGs, 100GB outbound) |
| **Time taken** | 4–6 hours across multiple sessions |
| **Cert alignment** | CompTIA Network+ · AZ-104 Azure Administrator · AZ-500 Azure Security Engineer |
| **Career relevance** | Cloud Engineer · Infrastructure Engineer · Cloud Security Analyst · DevOps Engineer |

---

## The Business Problem This Lab Solves

Every organisation migrating to Azure faces the same non-negotiable requirement before a single workload goes live: **the network must be secure by design, not secured after the fact.**

Network misconfiguration is the single most common cause of Azure support tickets and the most frequent security gap identified in enterprise cloud audits. Public endpoints left open, storage accounts reachable from the internet, flat networks with no traffic segmentation — these are not theoretical risks. They are the root cause of real data breaches in financial services, healthcare and government organisations.

In this lab, **Enterprise Corp** is migrating its core workloads to Azure under ISO/IEC 27001 compliance requirements. The infrastructure team must deliver:

- **Zero public internet exposure** for database and storage PaaS services
- **Centralised traffic control** through a dedicated Hub network
- **Micro-segmentation** between application and data tiers
- **Private DNS resolution** so PaaS FQDNs resolve to internal IPs only

This is the exact architecture a Cloud Engineer designs on day one of any enterprise Azure engagement.

| Role | How this lab applies |
|---|---|
| **Cloud Engineer** | VNets, subnets, NSGs, peering, private endpoints — the core daily toolkit |
| **Azure Architect** | Hub-and-Spoke is the standard enterprise Azure Landing Zone pattern |
| **Security Analyst** | NSG least-privilege rules and private endpoints are primary network security controls |
| **DevOps Engineer** | Network foundations underpin every CI/CD pipeline and AKS cluster |

---

## Network Architecture

```
[Hub VNet] (10.0.0.0/16)
├── GatewaySubnet      (10.0.1.0/24)  — Reserved for VPN/ExpressRoute Gateway
└── ManagementSubnet   (10.0.2.0/24)  — Administrative/jumpbox traffic
         │
    (VNet Peering — Fully Synchronized)
         │
[Spoke VNet] (10.1.0.0/16)
├── AppSubnet   (10.1.1.0/24) ────► [vm-app-test] (No Public IP) ─► NSG: nsg-spoke-app-eastus
└── DataSubnet  (10.1.2.0/24) ───► Private Endpoint (10.1.2.4)  ──► Storage Account (no public access)
                                            │
                                   Azure Private DNS Zone
                                   privatelink.blob.core.windows.net
                                   FQDN → 10.1.2.4 (internal only)
```

---

## What Was Built

- ✅ Resource Group provisioned with enterprise naming convention (`rg-networking-prod-eastus`)
- ✅ Hub VNet (`vnet-hub-prod-eastus`, 10.0.0.0/16) with GatewaySubnet and ManagementSubnet
- ✅ Spoke VNet (`vnet-spoke-prod-eastus`, 10.1.0.0/16) with AppSubnet and DataSubnet
- ✅ Bidirectional VNet Peering — status: **Connected / Fully Synchronized**
- ✅ NSG `nsg-spoke-app-eastus` with least-privilege inbound rules (Priority 100 allow, 65500 deny-all)
- ✅ NSG `nsg-data-prod` with strict source restriction from AppSubnet CIDR only
- ✅ Azure Storage Account (`stproddataeastus`) with **public access explicitly Disabled**
- ✅ Private Endpoint (`pe-storage-blob-prod`) deployed into DataSubnet
- ✅ Azure Private DNS Zone (`privatelink.blob.core.windows.net`) linked to Spoke VNet
- ✅ Test VM (`vm-app-test`) in AppSubnet with **no public IP** — accessed via Azure Bastion
- ✅ DNS resolution verified: `nslookup` resolves to private IP `10.1.2.4`
- ✅ Storage reachability verified: cURL to storage FQDN returns `HTTP/1.1 400` from `Microsoft-HTTPAPI/2.0`
- ✅ NSG Flow Logs configured via Network Watcher with 30-day retention
- ✅ KQL query executed in Log Analytics workspace (`law-spoke-prod-eastus`)

---

## Architecture Decisions — Why Each Choice Was Made

| Decision | Rationale | Enterprise Relevance |
|---|---|---|
| **Hub-and-Spoke Topology** | Centralises security policy, traffic inspection, and future Firewall/NVA deployment | Standard Azure Landing Zone pattern for regulated industries |
| **Private Endpoints over Service Endpoints** | Provides a dedicated private IP — eliminates public IP exposure completely | Service Endpoints still route via Azure backbone but retain public endpoint; Private Endpoints remove it entirely |
| **Public Access Disabled on Storage** | Enforces Zero-Trust from initial deployment — access only via private path | Financial services and healthcare compliance requirement (ISO 27001, PCI-DSS) |
| **Explicit NSG Rule Priorities** | Priority 100 permits required traffic; 65500 DenyAllInbound catches everything else | Least-privilege principle — deny by default, allow explicitly |
| **App-to-Data Tier Isolation** | DataSubnet NSG source restriction to AppSubnet CIDR (10.1.1.0/24) only | Prevents lateral movement — a compromised web server cannot directly reach the database tier |
| **VM with No Public IP** | All management via Azure Bastion over internal network | Zero-Trust network perimeter — no external attack vector on compute resources |

---

## Key Concepts Explained

### What is a Hub-and-Spoke Network?

Think of it like an airport hub. Every regional airport (spoke) connects through one major hub — not directly to each other. In Azure, the Hub VNet contains shared services (VPN gateway, firewall, monitoring). Spoke VNets contain workloads. Spokes cannot talk to each other directly — all traffic routes through the Hub where it can be inspected and controlled.

### What is VNet Peering?

Two separate Azure Virtual Networks connected privately over Microsoft's backbone network — never the public internet. Traffic between peered VNets is encrypted, low-latency, and invisible to the public. Peering must be configured in both directions (Hub→Spoke and Spoke→Hub) and both sides must show **Connected** status.

### What is a Private Endpoint?

Instead of a storage account having a public IP that any internet user could attempt to reach, a Private Endpoint projects a private network interface card (NIC) directly into your subnet with an internal IP address. The storage account's FQDN (`stproddataeastus.blob.core.windows.net`) resolves to `10.1.2.4` internally — a private address that only exists inside your network.

### What are NSG Rules?

Network Security Groups are Azure's built-in firewall rule engine. Rules are evaluated in priority order — lowest number wins. Priority 100 runs before Priority 200. The platform always ends with an implicit deny-all. In this lab, explicit allow rules at Priority 100 permit only the required traffic; everything else falls through to `DenyAllInbound` at Priority 65500.

---

## Files in This Repository

| File | Contents |
|---|---|
| `scripts/01-create-resource-group.ps1` | Provision resource group with naming convention |
| `scripts/02-create-hub-vnet.ps1` | Hub VNet and subnets — Azure PowerShell |
| `scripts/03-create-spoke-vnet.ps1` | Spoke VNet and subnets — Azure PowerShell |
| `scripts/04-configure-vnet-peering.ps1` | Bidirectional VNet peering |
| `scripts/05-create-nsgs.ps1` | NSG creation and rule configuration |
| `scripts/06-create-storage-private-endpoint.ps1` | Storage account, private endpoint, private DNS |
| `scripts/07-deploy-test-vm.ps1` | Test VM in AppSubnet with no public IP |
| `scripts/08-configure-flow-logs-kql.ps1` | Network Watcher flow logs and KQL telemetry |
| `verification/verify-lab2.ps1` | Full verification checklist — all resources |
| `verification/kql-flow-log-query.kql` | KQL query for Log Analytics telemetry |
| `screenshots/README.md` | Evidence index — all 12 sequential screenshots |
| `docs/DECISIONS.md` | Architecture decision record with full reasoning |

---

## Verification Checklist

| Check | Command / Location | Expected Result |
|---|---|---|
| Hub VNet exists | Portal → Virtual Networks | `vnet-hub-prod-eastus` with 2 subnets |
| Spoke VNet exists | Portal → Virtual Networks | `vnet-spoke-prod-eastus` with 2 subnets |
| VNet Peering connected | Hub VNet → Peerings | Status: **Connected / Fully Synchronized** |
| NSG applied to AppSubnet | Spoke VNet → AppSubnet → NSG | `nsg-spoke-app-eastus` associated |
| Storage public access disabled | Storage Account → Networking | Public network access: **Disabled** |
| Private Endpoint provisioned | DataSubnet → Connected devices | `pe-storage-blob-prod` at `10.1.2.4` |
| DNS resolves to private IP | `nslookup stproddataeastus.blob.core.windows.net` | Returns `10.1.2.4` |
| Storage reachable from VM | `curl -I https://stproddataeastus.blob.core.windows.net` | `HTTP/1.1 400` from `Microsoft-HTTPAPI/2.0` |
| Flow logs active | Network Watcher → Flow Logs | `nsg-spoke-app-eastus` — Enabled, 30-day retention |

---

## On-Premises to Azure Architecture Mapping

| On-Premises | Azure Equivalent | Business Benefit |
|---|---|---|
| VLANs / Core Switches | Virtual Networks & Subnets | Native cloud isolation — no physical switch configuration |
| Hardware Firewalls | Network Security Groups | Software-defined micro-segmentation — zero hardware overhead |
| MPLS / Leased Lines | VNet Peering | Low-latency private routing over Microsoft's enterprise backbone |
| Air-Gapped DMZ Network | Private Endpoints & Private DNS | Complete public internet isolation for sensitive PaaS resources |
| Jump Host / Bastion Server | Azure Bastion (ManagementSubnet) | Secure TLS-encrypted portal management — no public SSH/RDP ports |

---

## Skills Demonstrated

- Azure Virtual Network design, CIDR planning and subnet segmentation
- Hub-and-Spoke architecture with non-transitive VNet Peering
- Network Security Group configuration with least-privilege rule engineering
- Private Endpoint and Azure Private DNS Zone integration
- Zero-Trust network perimeter design
- Network Watcher flow log configuration and 30-day retention policy
- KQL telemetry queries in Log Analytics workspace
- PowerShell automation for all lab steps (IaC alternative to portal)

---

## Certification Alignment

| Lab Skill | Exam Objective |
|---|---|
| VNet design and CIDR planning | AZ-104: Configure and manage virtual networks |
| VNet Peering | AZ-104: Configure VNet peering |
| NSG rule engineering | AZ-104: Configure network security groups · AZ-500: Implement network security |
| Private Endpoints | AZ-104: Configure Azure DNS · AZ-500: Configure private endpoints |
| KQL in Log Analytics | AZ-104: Monitor resources with Azure Monitor |
| PowerShell automation | AZ-104: Automate deployment and configuration |

---

## Cloud Engineering Mapping — Lab 1 to Lab 2

| Lab 1 — Active Directory | Lab 2 — Azure Networking |
|---|---|
| Domain = identity boundary | VNet = network boundary |
| OU structure = logical grouping | Subnets = network segmentation |
| GPO = policy enforcement | NSG rules = traffic policy enforcement |
| Domain join = managed asset | VNet membership = managed network resource |
| DSRM recovery = break-glass | Gateway Subnet = hybrid connectivity fallback |

Both labs build the same foundational principle: **structure first, access by exception, deny by default.**

---

*Part of a structured cloud engineering portfolio — Lab 1: Active Directory | Lab 2: Azure Networking | Lab 3: Azure Identity | Lab 4: KQL & Azure Monitor | Lab 5: Terraform on Azure*

**Emmanuel Onen · Senior Systems Engineer · Cayman Islands**
*Certification path: AZ-900 → AZ-104 → AI-102 → AZ-400*
*GitHub: [github.com/emmanuelonen](https://github.com/emmanuelonen)*
