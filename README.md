# Azure Automation

PowerShell scripts I wrote and collected while managing Azure: creating and scheduling VMs, moving disks around, networking, SQL backups, access reports. Most were written for the old AzureRM module, so expect to adapt them for `Az`.

All identifying values (passwords, keys, tokens, subscription and tenant IDs, hostnames, email addresses) have been replaced with placeholders such as `<PASSWORD>`, `<SUBSCRIPTION_ID>` and `user@contoso.com`. Fill them in or, better, pull them from Key Vault or Automation variables.

## Folders

- `virtual-machines/` create, create-parallel, power-management, resize-and-extensions, guest-os
- `disks-and-storage/` managed-disks, snapshots, vhd-and-images, blob-storage
- `networking/` nic-and-nsg, dns, load-balancing-and-nat, vmss
- `automation-runbooks/` accounts-and-jobs, webhooks, notifications
- `application-gateway/`
- `databases/`
- `identity-and-access/`
- `microsoft-365/`
- `monitoring-and-reporting/`
- `resource-management/`
- `archive/` older versions and bundles

How-to documents sit next to the scripts they describe. Variants of a script have a `-v2` suffix.

Test anything in a non-production subscription first.
