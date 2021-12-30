Login-AzureRMAccount

$subscriptionId = 'yourSubscriptionId'
 
$resourceGroupName ='notif-workergroup-1'
$virtualMachineName = 'notif-workergroup-1'
$virtualMachineSize = 'Standard_DS2'
$NICName = "notif-workergroup-1" 
$snapshotName = 'notif-workergroup-1'
 
$osDiskName = $virtualMachineName +"OSDISK"
 
Select-AzureRmSubscription -SubscriptionId $SubscriptionId

$nic = Get-AzureRMNetworkInterface -Name $NICName -ResourceGroupName $resourceGroupName

$snapshot = Get-AzureRmSnapshot -ResourceGroupName $resourceGroupName -SnapshotName $snapshotName
 
$diskConfig = New-AzureRmDiskConfig -AccountType $storageType -Location $snapshot.Location -SourceResourceId $snapshot.Id -CreateOption Copy
 
$disk = New-AzureRmDisk -Disk $diskConfig -ResourceGroupName $resourceGroupName -DiskName $osDiskName
 
$VirtualMachine = New-AzureRmVMConfig -VMName $virtualMachineName -VMSize $virtualMachineSize
 
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -ManagedDiskId $disk.Id -CreateOption Attach -Linux
 
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $nic.Id
 
#Create the virtual machine with Managed Disk
New-AzureRmVM -VM $VirtualMachine -ResourceGroupName $resourceGroupName -Location $snapshot.Location
