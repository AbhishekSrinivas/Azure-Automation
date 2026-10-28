$StorageAccountName="newteststorage1"

$StorageAccountKey=<STORAGE_ACCOUNT_KEY>

#$File = "D:\testing\exportingtrail.csv"


$context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
 
$containers=Get-AzureStorageContainer -Context $context    
foreach($container in $containers)    
{    


$cntname= $container.Name    
    
$context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

$filelist = Get-AzureStorageBlob -Container $cntname -Context $context

#$filelist


foreach ($file in $filelist)
{
$storageurl = $file.Context.BlobEndPoint
#$storageurl
$FileName = $file.Name

$FileURL = $storageurl + "" + $cntname +"/"+ $FileName

#$FileURL 

}

$FileURL | Out-File D:\testing\exportingt.csv

}