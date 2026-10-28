# Azure Automation Scripts

A collection of PowerShell scripts and runbooks for automating common Azure administration tasks: virtual machine lifecycle, disks and storage, networking, scheduling, SQL backups, identity and reporting.

> **Status:** reference collection. Many scripts were written against the older `AzureRM` module and classic runbook patterns. Review and adapt them (for example to the `Az` module) before running in any environment.

## Sanitized content

All identifying values have been replaced with placeholders:

| Placeholder | Meaning |
|---|---|
| `<PASSWORD>` | Any password or secret. Supply at runtime, never hard-code. |
| `<STORAGE_ACCOUNT_KEY>` | Storage account access key |
| `<WEBHOOK_TOKEN>` | Azure Automation webhook token |
| `<SUBSCRIPTION_ID>`, `<TENANT_ID>`, `<CLIENT_ID>`, `<GUID>` | Azure identifiers |
| `user@contoso.com` | Any email address |
| `<sql-server-host>`, `<storage-account>`, `<vm-dns-name>` | Hostnames |

Use `Get-Credential`, Azure Key Vault, or Automation account variables and credentials instead of literal secrets.

## Layout

| Folder | Contents |
|---|---|
| `VM-Creation/` | Creating single and multiple VMs from images, snapshots and VHDs |
| `Power-Scheduling-and-Runbooks/` | Start/stop schedules, webhooks, runbook helpers, resizing |
| `Disks-and-Storage/` | Managed disks, VHDs, snapshots, blob copy and retention |
| `Networking-and-DNS/` | NICs, NSGs, VMSS, load balancer, DNS records |
| `Application-Gateway/` | Gateway scaling, probes, listeners and certificates |
| `SQL-and-Databases/` | SQL PaaS backups, exports and tier resizing |
| `Identity-and-Access/` | Service principals, IAM roles, Microsoft 365 user tasks |
| `Reporting-and-Inventory/` | Exports of VM, NSG, disk and activity data |
| `Docs/` | Short how-to documents |
| `Misc/` | Module installs, resource provider registration and utilities |
| `Archive/` | Older versions, extracted bundles and scratch files |

## Getting started

```powershell
Install-Module Az -Scope CurrentUser
Connect-AzAccount
```

Then open the script you need, replace the placeholders and review it before running.

## Contributing and safety

- Never commit credentials, keys, tokens or tenant data. The `.gitignore` blocks common secret file types.
- Test in a non-production subscription first.
