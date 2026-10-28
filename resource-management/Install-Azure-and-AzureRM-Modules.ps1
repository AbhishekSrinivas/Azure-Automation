
Install-Module -Name Az -AllowClobber


Install-Module -Name AzureRM -AllowClobber

Import-Module AzureRM

Get-InstalledModule -Name AzureRM -AllVersions | select Name,Version