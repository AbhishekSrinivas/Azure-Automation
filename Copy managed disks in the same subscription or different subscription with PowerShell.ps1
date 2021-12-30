Login-AzureRmAccount

#Provide the subscription Id of the subscription where managed disk exists
$sourceSubscriptionName= "G7CRM4L008"

#Provide the name of your resource group where managed disk exists
$sourceResourceGroupName='SPARTAN'

#Provide the name of the managed disk
$managedDiskName='logvm1_OsDisk_1_d5e17b39c1d44a9d84892388d66df961'

#Set the context to the subscription Id where Managed Disk exists
Select-AzureRmSubscription -SubscriptionName $sourceSubscriptionName

#Get the source managed disk
$managedDisk= Get-AzureRMDisk -ResourceGroupName $sourceResourceGroupName -DiskName $managedDiskName



$TargetSubscriptionName = "G7CRM4L007"

#Provide the subscription Id of the subscription where managed disk will be copied to
#If managed disk is copied to the same subscription then you can skip this step
$TargetSubscriptionName = $TargetSubscriptionName

#Name of the resource group where snapshot will be copied to
$targetResourceGroupName= "ManagedDISKCP"

#Set the context to the subscription Id where managed disk will be copied to
#If snapshot is copied to the same subscription then you can skip this step
Select-AzureRmSubscription -SubscriptionName $TargetSubscriptionName

New-AzureRmResourceGroup -Name $targetResourceGroupName -Location $managedDisk.Location

$diskConfig = New-AzureRmDiskConfig -SourceResourceId $managedDisk.Id -Location $managedDisk.Location -CreateOption Copy 

#Create a new managed disk in the target subscription and resource group
New-AzureRmDisk -Disk $diskConfig -DiskName $managedDiskName -ResourceGroupName $targetResourceGroupName