# Azure Automation

PowerShell scripts I wrote and collected while managing Azure. They cover creating and scheduling VMs, moving disks, networking, SQL backups and access reports. Most use the old AzureRM module, so adapt them for `Az` before you run them.

I replaced every identifying value (passwords, keys, tokens, subscription and tenant IDs, hostnames and email addresses) with a placeholder such as `<PASSWORD>`, `<SUBSCRIPTION_ID>` or `user@contoso.com`. Fill them in, or better, read them from Key Vault or Automation variables.

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
