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
| `virtual-machines/create` | Create single or multiple VMs from images, snapshots, VHDs and Marketplace images (with ARM `templates/`) |
| `virtual-machines/create-parallel` | Parallel VM creation using workflows |
| `virtual-machines/power-management` | Start, stop and schedule VMs, including weekday-only variants |
| `virtual-machines/resize-and-extensions` | VM size changes, extensions, availability sets |
| `virtual-machines/guest-os` | In-guest scripts and notes |
| `disks-and-storage/managed-disks` | Copy, convert, swap and inspect managed disks |
| `disks-and-storage/snapshots` | Snapshot creation |
| `disks-and-storage/vhd-and-images` | VHD upload and download, managed images |
| `disks-and-storage/blob-storage` | Blob copy, upload, size and retention clean-up |
| `networking/` | `nic-and-nsg`, `dns`, `load-balancing-and-nat`, `vmss` |
| `application-gateway` | Gateway scaling, probes, listeners and certificates |
| `automation-runbooks/` | `accounts-and-jobs`, `webhooks`, `notifications` |
| `databases` | SQL PaaS backups, exports and tier resizing, MySQL insert |
| `identity-and-access` | Service principals, IAM role actions, bulk users |
| `microsoft-365` | Aliases, Teams, mailbox and group tasks |
| `monitoring-and-reporting` | VM, NSG, disk and activity exports |
| `resource-management` | Resource groups, providers, modules and authentication |
| `docs` | Short how-to documents |
| `archive` | Older versions and bundled sets, kept for reference |

Files follow `Verb-Noun-Detail` naming in kebab-case. Variants of the same script carry a `-v2` suffix.

## Getting started

```powershell
Install-Module Az -Scope CurrentUser
Connect-AzAccount
```

Then open the script you need, replace the placeholders and review it before running.

## Contributing and safety

- Never commit credentials, keys, tokens or tenant data. The `.gitignore` blocks common secret file types.
- Test in a non-production subscription first.
