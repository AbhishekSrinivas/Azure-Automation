workflow Get-VM-Guest-Logs
{

Param 
    (

        [Parameter(Mandatory=$true)]
        [String] $TenantID,

        [Parameter(Mandatory=$true)]
        [String] $AppID,

        [Parameter(Mandatory=$true)]
        [String] $AppSecretKey,

        [Parameter(Mandatory=$true)]
        [String] $STGRGName,

        [Parameter(Mandatory=$true)]
        [String] $STGName,

        [Parameter(Mandatory=$true)]
        [String] $STGContainer

    )

$ScriptLocation = $env:TEMP + "\"
#$LinuxDiskSize = "LinuxDiskSize.sh"
$WindowsHostName = "script.ps1"


$cred = New-Object PSCredential $AppID, ($AppSecretKey | ConvertTo-SecureString -AsPlainText -Force)

Connect-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $TenantID 

InlineScript {

        $stg = Get-AzureRmStorageAccount -ResourceGroupName $Using:STGRGName -Name $Using:STGName
        
        $srcContext = $stg.Context

#        Get-AzureStorageBlobContent -Blob $LinuxDiskSize -Container $STGContainer -Destination $ScriptLocation -Context $srcContext -Force
        
        Get-AzureStorageBlobContent -Blob $Using:WindowsHostName -Container $Using:STGContainer -Destination $Using:ScriptLocation -Context $srcContext -Force

}
$LinuxSrciptPath = $ScriptLocation + $LinuxDiskSize
$WindowsScriptPath = $ScriptLocation + $WindowsHostName


#$ErrorActionPreference = "SilentlyContinue"

$VMS = Get-AzureRMVM

Foreach -Parallel ($VM in $VMS)

{

    $VMName = $VM.Name
    $RGName = $VM.ResourceGroupName
    $OSType = $VM.StorageProfile.OsDisk.OsType

    $VMName

    $vmstatus = (Get-AzureRmVM -Name $VMName -ResourceGroupName $RGName -Status).Statuses | Where-Object {$_.Code -like "PowerState/*"}

    $VMStatus = $vmstatus.DisplayStatus

        InLineScript {

                $VMName = $Using:VMName
                $RGName = $Using:RGName
                $OSType = $Using:OSType

                If ($Using:VMStatus -eq "VM running")

                    {

                        if ($OSType -eq "Linux")

                            {
                                Write-Output "Linux OS VM ' $VMName ' is Running"
                        
                                $diskuti = Invoke-AzureRmVMRunCommand -VMName $VMName -ResourceGroupName $RGName `
                                -CommandId 'RunShellScript' -ScriptPath $Using:LinuxSrciptPath

                                $diskuti.Value
                            }


                        Else
                            {
                                Write-Output "Windows OS VM ' $VMName ' is Running"

                                $diskuti = Invoke-AzureRmVMRunCommand -VMName $VMName -ResourceGroupName $RGName `
                                -CommandId 'RunPowerShellScript' -ScriptPath $Using:WindowsScriptPath

                                $diskuti.Value
                            }

                    }
                }
                
        }

}