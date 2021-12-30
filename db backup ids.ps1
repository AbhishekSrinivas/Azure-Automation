
param(
    [parameter(Mandatory=$true)]
    [String] $AutomationConnection,
    [parameter(Mandatory=$true)]
    [String] $SubscriptionName,
    [parameter(Mandatory=$true)]
    [String]$StorageAccount,
    [parameter(Mandatory=$true)]
    [String]$BlobContainer,
    [parameter(Mandatory=$true)]
    [String]$StorageKey,
    [parameter(Mandatory=$true)]
    [String]$StorageKeytype = "StorageAccessKey",
    [parameter(Mandatory=$true)]
    [String]$DbName,
    [parameter(Mandatory=$true)]
    [String]$ResourceGroupName,
    [parameter(Mandatory=$true)]
    [String]$ServerName,
    [parameter(Mandatory=$true)]
    [String]$serverAdmin,
    [parameter(Mandatory=$true)]
    [String]$ServerPassword
)
 
$VERSION = "0.2.0"
$currentTime = (Get-Date).ToUniversalTime()
 
Write-Output "Backup SQL Azure db automation script - version $VERSION"
Write-Output "Runbook started..."
 
# Main runbook content
try
{
$securePassword = ConvertTo-SecureString -String $serverPassword -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $serverAdmin, $securePassword
 
# Generate a unique filename for the BACPAC
$bacpacFilename = $ServerName + '-' + $DbName + '-' +(Get-Date).ToString("yyyyMMdd") + ".bacpac"
 
#$bacpacFilename = $ServerName + '-' + $DbName + '-' +(Get-Date).AddDays(-1).ToString("yyyyMMdd") + ".bacpac"
 
# Storage account info for the BACPAC
$BaseStorageUri = "https://$storageAccount.blob.core.windows.net/$blobContainer/"
$BacpacUri = $BaseStorageUri + $bacpacFilename
 
    Write-Output "Logging in to Azure..."
# Get the connection
$con = Get-AutomationConnection -Name $AutomationConnection
$null = Add-AzureRmAccount -ServicePrincipal -TenantId $con.TenantId -ApplicationId $con.ApplicationId -CertificateThumbprint $con.CertificateThumbprint
$null = Select-AzureRmSubscription -SubscriptionName $SubscriptionName
 
    Write-Output "Will backup db $DbName to $blobContainer blob storage in storage account $storageAccount with name $bacpacFilename ..."
$exportRequest = New-AzureRmSqlDatabaseExport -ResourceGroupName $ResourceGroupName -ServerName $ServerName `
       -DatabaseName $DbName -StorageKeytype $StorageKeytype -StorageKey $StorageKey -StorageUri $BacpacUri `
       -AdministratorLogin $creds.UserName -AdministratorLoginPassword $creds.Password
 
# Check status of the export
$status = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink
 
    Write-Output "Export status is:"
$status
}
catch
{
if (!$con)
    {
$ErrorMessage = "Connection $connectionName not found."
throw$ErrorMessage
    } else{
        Write-Error -Message $_.Exception
throw$_.Exception
    }
}
finally
{
"Runbook finished (Duration: $(("{0:hh\:mm\:ss}" -f ((Get-Date).ToUniversalTime() - $currentTime))))"
}

