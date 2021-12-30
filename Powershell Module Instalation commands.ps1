$sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$targetNugetExe = "$rootPath\nuget.exe"
Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe
Set-Alias nuget $targetNugetExe -Scope Global -Verbose


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


install-module

Set-ExecutionPolicy Unrestricted

Install-Module PowerShellGet -Force

Register-PSRepository -Default

Install-Module -Name AzureRM -AllowClobber