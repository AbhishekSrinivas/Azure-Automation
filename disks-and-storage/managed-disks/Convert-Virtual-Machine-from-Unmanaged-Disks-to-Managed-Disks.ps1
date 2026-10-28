Login-AzureRmAccount 

Select-AzureRmSubscription -Subscription "ContosoContoso007"

$rgName = "sqlyassh"
$vmName = "sqlyash"

Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force


ConvertTo-AzureRmVMManagedDisk -ResourceGroupName $rgName -VMName $vmName


Start-AzureRmVM -ResourceGroupName $rgName -Name $vmName