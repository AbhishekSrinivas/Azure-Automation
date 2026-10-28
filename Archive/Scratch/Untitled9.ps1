#$container="newtestcontainer"

$StorageAccountName="newteststorage1"

$StorageAccountKey=<STORAGE_ACCOUNT_KEY>


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

$FileURL = $storageurl + "" + $cntname +"/"+ $file.Name

$FileURL

}
}