Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName "your Subscritption Name"

$RGName = "VM-OSDIsk-RGName" 
$DiskName = "Managed-OSDisk-Name"

$StorageAccount = "StorageAccount-Name"
$STGKey = "StorageAccount-Key"
$ContainerName = "vhds"

$VHDName = "Give-Some-Name-to-YourVHD.vhd"

$sas = Grant-AzureRmDiskAccess -ResourceGroupName $RGName -DiskName $DiskName -DurationInSecond 3600 -Access Read 
$destContext = New-AzureStorageContext –StorageAccountName $StorageAccount -StorageAccountKey $STGKey 
$blob1 = Start-AzureStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestContainer $ContainerName -DestContext $destContext -DestBlob $VHDName

## Retrieve the current status of the blob copy operation ###
$status = $blob1 | Get-AzureStorageBlobCopyState
  
### Print out status ### 
$status
  
### Loop until complete ###                                    
While($status.Status -eq "Pending"){
  $status = $blob1 | Get-AzureStorageBlobCopyState
  Start-Sleep 10
  ### Print out status ###
  $status
}

