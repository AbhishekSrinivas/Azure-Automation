#Login-AzureRmAccount

Param 
    (
        [Parameter(Mandatory=$true)]
        [String] $AppName,

        [Parameter(Mandatory=$true)]
        [String] $AppSecretKey
    )



$Tenant = Get-AzureRmSubscription
#$TenantID = "<TENANT_ID>"
$TenantID = $Tenant.TenantID

$LinuxSrciptPath = "C:\Users\User\Desktop\Subex\DiskSize\LinuxDiskSzie.ps1"
#$WindowsScriptPath = "C:\Users\User\Desktop\Subex\DiskSize\WindowsHostName.ps1"

$OutputFileLocation = "C:\users\user\desktop\subex\DiskSize\"

$application = Get-AzureRmADApplication -DisplayNameStartWith $AppName

$svcprincipal = Get-AzureRmADServicePrincipal -ApplicationId $application.ApplicationId
$svcprincipal | Select-Object *

$AppUsername = $svcprincipal.ApplicationId

$cred = New-Object PSCredential $AppUsername, ($AppSecretKey | ConvertTo-SecureString -AsPlainText -Force)

Connect-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $TenantID 

     
$LinuxSrciptPath
#$WindowsScriptPath

$VMS = Get-AzureRMVM

Foreach ($VM in $VMS)

{

$ErrorActionPreference = "SilentlyContinue"

$VMName = $VM.Name
$RGName = $VM.ResourceGroupName


$vmstatus = (Get-AzureRmVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Status).Statuses | Where-Object {$_.Code -like "PowerState/*"}


if ($vmstatus.DisplayStatus -eq "VM Running")

    {


        if ($VM.StorageProfile.OsDisk.OsType -eq "Linux")

            {

                Write-Output "$VMName is running - OSType = Linux"
                $FileLocation = $OutputFileLocation+ "$VMName" + ".txt"
                $FileName = $VMName + ".txt"
                     
                $diskuti = Invoke-AzureRmVMRunCommand -VMName $VMName -ResourceGroupName $RGName -CommandId 'RunShellScript' -ScriptPath $LinuxSrciptPath

                        $diskuti.Value + $VMName | Out-File -FilePath $FileLocation                            
                    
                        $FileName
            }
 

        <#Else
        
             {

                Write-Output "$VMName is running - OSType = Windows"
                $FileLocation = $OutputFileLocation+ "$VMName" + $time + ".txt"
                $FileName = $VMName + $time + ".txt"
           
                $diskuti = Invoke-AzureRmVMRunCommand -VMName $VMName -ResourceGroupName $RGName -CommandId 'RunPowerShellScript' -ScriptPath $WindowsSrciptPath

                        $diskuti.Value

                        $diskuti.Value | Out-File -FilePath $FileLocation

                        Set-AzureStorageBlobContent -File $FileLocation -Container $STGContainer -Blob $FileName -Context $srcContext 

                        $FileName
            }
            #>

    }
            
}
