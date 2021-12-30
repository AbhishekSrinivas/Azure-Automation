
#Login-AzureRmAccount



Select-AzureRmSubscription -SubscriptionName "INDIA-TB"

$Location = "Central India"
$VMName = "NikshayProd"
$RGName = "Nikshay-DB-RG"
$DiskName = ""
 
$disk = Get-AzureRmDisk -ResourceGroupName $RGName -Name $DiskName


$vm = Get-AzureRMVM -Name $VMName -ResourceGroupName $RGName

Stop-AzureRmVM -Name $VMName -ResourceGroupName $RGName -Force


#$vm.StorageProfile.OsDisk.ManagedDisk.Id = $disk.Id

Set-AzureRmVMOSDisk -VM $vm -Name $disk.Name -ManagedDiskId $disk.id


Update-AzureRmVM -ResourceGroupName $RGName -VM $vm 

Start-AzureRMVM -Name $VMName -ResourceGroupName $RGName