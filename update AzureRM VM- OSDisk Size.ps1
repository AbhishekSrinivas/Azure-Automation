# Sign-in with Azure account credentials
Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "G7CRM4L008"

$RGName = "MPHMySQLTemp"
$VMName = "MPHMySQLTemp"

$vm = Get-AzureRmVM -ResourceGroupName $RGName -Name $VMName

Stop-AzureRmVM -ResourceGroupName $RGName -Name $VMName -Force

$vm.StorageProfile.OSDisk.DiskSizeGB = 127
Update-AzureRmVM -ResourceGroupName $RGName -VM $vm