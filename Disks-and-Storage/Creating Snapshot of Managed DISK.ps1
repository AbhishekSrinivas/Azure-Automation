Select-AzureRmProfile -Path C:\Users\adm_user\Desktop\contoso.json

Select-AzureRmSubscription -SubscriptionName "ContosoContoso09"


$SDSKRGName = "captest3538887409000"
$Location = "CentralIndia" 
$DiskName = "VS2015ENTU3" 
$snapshotName = "$DiskName"
$DDSKRGName = "ContosoTemplates"

$disk = Get-AzureRmDisk -ResourceGroupName $SDSKRGName -DiskName $DiskName

$snapshot =  New-AzureRmSnapshotConfig -SourceUri $disk.Id -CreateOption Copy -Location $Location

New-AzureRmSnapshot -ResourceGroupName $DDSKRGName -SnapshotName $snapshotName -Snapshot $snapshot
 

