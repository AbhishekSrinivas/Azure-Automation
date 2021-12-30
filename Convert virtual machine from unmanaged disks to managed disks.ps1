Login-AzureRmAccount 

Select-AzureRmSubscription -Subscription "G7CRM4L007"

$rgName = "sqlyassh"
$vmName = "sqlyash"

Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force


ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $rgName -VMName $vmName


Start-AzureRmVM -ResourceGroupName $rgName -Name $vmName