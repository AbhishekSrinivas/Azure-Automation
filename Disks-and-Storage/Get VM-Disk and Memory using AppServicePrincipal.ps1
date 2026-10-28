#Login-AzureRmAccount

$Tenant = Get-AzureRmSubscription

$LinuxDiskSize = $env:TEMP+ "C:\Users\User\Desktop\Subex\DiskSize\LinuxDiskSzie.ps1"
$WindowsHostName = "C:\Users\User\Desktop\Subex\DiskSize\WindowsHostName.ps1"

$TenantID = $Tenant.TenantId

$AppName = "userapp"
$STGRGName = "Subex-LinuxVHDImages"
$STGName = "vmdetailslog"
$STGContainer = "logs"


$application = Get-AzureRmADApplication -DisplayNameStartWith $AppName


$svcprincipal = Get-AzureRmADServicePrincipal -ApplicationId $application.ApplicationId
$svcprincipal | Select-Object *

$AppUsername = $svcprincipal.ApplicationId
$AppSecretKey = "<STORAGE_ACCOUNT_KEY>"


$cred = New-Object PSCredential $AppUsername, ($AppSecretKey | ConvertTo-SecureString -AsPlainText -Force)


Connect-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $TenantID 


$VMS = Get-AzureRMVM

                
            $stg = Get-AzureRmStorageAccount -ResourceGroupName $STGRGName -Name $STGName
            $cnt = Get-AzureStorageContainer -Name $STGContainer -Context $stg.Context

            $ctx = $stg.Context


Foreach ($VM in $VMS)

{

 $VMName = $VM.Name
 $RGName = $VM.ResourceGroupName

        if ($VM.StorageProfile.OsDisk.OsType -eq "Linux")

            {

                $VMName
                $FileLocation = $env:TEMP+ "\$VMName" + ".txt"
                $FileName = $VMName + ".txt"
                     
                $diskuti = Invoke-AzureRmVMRunCommand -VMName $VMName -ResourceGroupName $RGName -CommandId 'RunShellScript' -ScriptPath $LinuxDiskSize

                        $diskuti.Value | Out-File -FilePath $FileLocation

                        Set-AzureStorageBlobContent -File $FileLocation -Container $STGContainer -Blob $FileName -Context $ctx                               
                    
                        $FileName
            }
 

        Elseif ($VM.StorageProfile.OsDisk.OsType -eq "Windows")

            {

                $VMName
                $FileLocation = $env:TEMP+ "\$VMName" + ".txt"
                $FileName = $VMName + ".txt"
           
                $diskuti = Invoke-AzureRmVMRunCommand -VMName $VMName -ResourceGroupName $RGName -CommandId 'RunPowerShellScript' -ScriptPath $WindowsHostName


                        $diskuti.Value | Out-File -FilePath $FileLocation

                        Set-AzureStorageBlobContent -File $FileLocation -Container $STGContainer -Blob $FileName -Context $ctx 

                        $FileName
            }

            
}
