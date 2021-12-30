

#Login-AzureRmAccount 

Select-AzureRmSubscription -Subscription "SALLP-Support-AZURE-CSP"

$RGName = "PR-17397"
$VMName = "PR17397-Telus-FMS-Lakshman"

$New_OSDISK = "https://pr17397telusfmslakshstd.blob.core.windows.net/vhds/PR17397-Telus-FMS-Lakshman.vhd"


$VM = Get-AzureRMVM -Name $VMName -ResourceGroupName $RGName

Stop-AzureRmVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Force

$VM.StorageProfile.OsDisk.Vhd.Uri = $New_OSDISK

Update-AzureRmVM -VM $VM -ResourceGroupName $RGName


