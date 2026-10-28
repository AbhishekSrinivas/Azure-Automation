$file = Get-ChildItem $location # use "-Filter *.bak" or "-Filter *.trn" for deleting bak or trn files specifically

$container="newtestcontainer"

$StorageAccountName="newteststorage1"

$StorageAccountKey=<STORAGE_ACCOUNT_KEY>

$context = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$filelist = Get-AzureStorageBlob -Container $container -Context $context

#$filelist


foreach ($file in $filelist)
{
$storageurl = $file.Context.BlobEndPoint
#$storageurl

$FileURL = $storageurl + "" + $container +"/"+ $file.Name

$FileURL

}
