Param 
    (
        [Parameter(Mandatory=$true)]
        [String] $SQLServer,

        [Parameter(Mandatory=$true)]
        [String] $ResourceGroupName,

        [Parameter(Mandatory=$true)]
        [String] $StorageAccName,

        [Parameter(Mandatory=$true)]
        [String] $StorageAccKey,

        [Parameter(Mandatory=$true)]
        [String] $Username,

        [Parameter(Mandatory=$true)]
        [String] $Password

        )

"#******************************* Login to Azure Run As Connection ********************************************#"
$connectionName = "AzureRunAsConnection"
    
Try
    {
# Get the connection "AzureRunAsConnection"
        
            $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

"Logging in to Azure..."

            Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }

Catch 
    {
        if (!$servicePrincipalConnection)
            {
                $ErrorMessage = "Connection $connectionName not found."
                throw $ErrorMessage
            } 
        else
            {
                Write-Error -Message $_.Exception
                throw $_.Exception
                $ErrorMessage = $_.Exception

            }
    }   
"#******************************* Successfully Logged in to Azure Run As Connection ********************************#"

Try 
{

        $CurrentTime = Get-Date
        $ISTtime = $CurrentTime.AddMinutes(330)

        $CDateTime = $ISTtime.ToString("yyyyMMdd")


        $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $securePassword

        $STGAcc = Get-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccName

        $ctx = $STGAcc.Context

        $DBS = Get-AzureRmSqlDatabase -ServerName $SQLServer -ResourceGroupName $ResourceGroupName 

        $Databases = $DBS.DatabaseName -ne "master"

        Foreach ($Database in $Databases)

        {

            $Database


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

                    While($status.Status -eq "InProgress")
                    {
                          $status = $ExportDB | Get-AzureRmSqlDatabaseImportExportStatus
                          Start-Sleep 10
                          ### Print out status ###
                          $status
                    }
                }

                else 
                {

                        Write-Output "-Else"


                        $DBCNTName = $DBCNT -replace "_","-"


                        New-AzureStorageContainer -Name $DBCNTName -Context $ctx

                        Start-Sleep -Seconds "10"

                        $StorageUri = "https://$StorageAccName.blob.core.windows.net/$DBCNTName/"

                        $BackupUri = $StorageUri + $BackupDBName

                        $BackupDBName
                        $BackupUri

                        $ExportDB = New-AzureRmSqlDatabaseExport -DatabaseName $Database -ServerName $SQLServer -ResourceGroupName $ResourceGroupName `
                                    -AdministratorLogin $Creds.UserName -AdministratorLoginPassword $Creds.Password -StorageKey $StorageAccKey -StorageUri $BackupUri `
                                    -StorageKeyType "StorageAccessKey"


                        $Status = $ExportDB | Get-AzureRmSqlDatabaseImportExportStatus

                        While($status.Status -eq "InProgress")
                        {
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