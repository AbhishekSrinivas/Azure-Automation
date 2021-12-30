Select-AzureRmProfile -Path C:\Users\adm_gulab\Desktop\m4l.json

Select-AzureRmSubscription -SubscriptionName "G7CRM4L09"


$SDSKRGName = "captest3538887409000"
$Location = "CentralIndia" 
$DiskName = "VS2015ENTU3" 
$snapshotName = "$DiskName"
$DDSKRGName = "M4LTemplates"

$disk = Get-AzureRmDisk -ResourceGroupName $SDSKRGName -DiskName $DiskName

$snapshot =  New-AzureRmSnapshotConfig -SourceUri $disk.Id -CreateOption Copy -Location $Location

New-AzureRmSnapshot -ResourceGroupName $DDSKRGName -SnapshotName $snapshotName -Snapshot $snapshot
 

