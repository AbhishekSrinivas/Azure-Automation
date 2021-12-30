#Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "Visual Studio Enterprise – MPN"


$Username = "labadmin"
$Password = "P@ssw0rd@123"

$ResourceGroupName = "SQL-Test"
$SQLServer = "sqlforfortuneserver" 
$StorageAccName = "sqltestdb"
$StorageAccKey = "DDpusFOT3ibCwM/OzNrOgZpizpf72NzIKlTu/FJDn32RlCa12SsxOOLm/OcVSiq5tir8VOypEWsrL+uUQ5FgmA=="
 


Try {

$CurrentTime = Get-Date

$CDateTime = $CurrentTime.ToString("yyyyMMdd-HHmm")

$securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $securePassword

$STGAcc = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccName

$DBS = Get-AzureRmSqlDatabase -ServerName $SQLServer -ResourceGroupName $ResourceGroupName 

$Databases = $DBS.DatabaseName -ne "master"

Foreach ($Database in $Databases)

{

$BackupDBName = $Database + "-" + $CDateTime + ".bacpac"

$DBCNT = $Database.ToLower()

$STGCNT = Get-AzureStorageContainer -Context $STGAcc.Context

If ($STGCNT.Name -eq $DBCNT)

    {

        Write-Output "-IF"

        
        $StorageUri = "https://$StorageAccName.blob.core.windows.net/$DBCNT/"

        $BackupUri = $StorageUri + $BackupDBName

        $BackupDBName
        $BackupUri

        $ExportDB = New-AzureRmSqlDatabaseExport -DatabaseName $Database -ServerName $SQLServer -ResourceGroupName $ResourceGroupName `
                    -AdministratorLogin $Creds.UserName -AdministratorLoginPassword $Creds.Password -StorageKey $StorageAccKey -StorageUri $BackupUri `
                    -StorageKeyType "StorageAccessKey"


        $Status = $ExportDB | Get-AzureRmSqlDatabaseImportExportStatus

        While($status.Status -eq "InProgress"){
          $status = $ExportDB | Get-AzureRmSqlDatabaseImportExportStatus
          Start-Sleep 10
          ### Print out status ###
          $status
          }
        }

else {

        Write-Output "-Else"

        $DBCNTName = $DBCNT -replace "_","-"

        New-AzureStorageContainer -Name $DBCNTName -Context $STGAcc.Context

        Start-Sleep -Seconds "10"

        $StorageUri = "https://$StorageAccName.blob.core.windows.net/$DBCNTName/"

        $BackupUri = $StorageUri + $BackupDBName

        $BackupDBName
        $BackupUri

        $ExportDB = New-AzureRmSqlDatabaseExport -DatabaseName $Database -ServerName $SQLServer -ResourceGroupName $ResourceGroupName `
                    -AdministratorLogin $Creds.UserName -AdministratorLoginPassword $Creds.Password -StorageKey $StorageAccKey -StorageUri $BackupUri `
                    -StorageKeyType "StorageAccessKey"


        $Status = $ExportDB | Get-AzureRmSqlDatabaseImportExportStatus

        While($status.Status -eq "InProgress"){
          $status = $ExportDB | Get-AzureRmSqlDatabaseImportExportStatus
          Start-Sleep 10
          ### Print out status ###
          $status
          }

        }
    }
}

Catch 
        {
            write-output "Exception Caught..."
            $ErrorMessage = $_.Exception.Message
            Write-Output "Error Occurred: Message: $ErrorMessage"
            
        }

