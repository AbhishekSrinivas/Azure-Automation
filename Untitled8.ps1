$file = Get-ChildItem $location # use "-Filter *.bak" or "-Filter *.trn" for deleting bak or trn files specifically

$container="newtestcontainer"

$StorageAccountName="newteststorage1"

$StorageAccountKey="LpOeCWs74z/PXFncIH1/gFpmO5qDztilOY1jIE6OUYt32u+WGoa2sb3p+l/RBXJyuJIJ7TNbsFIhHSOzmu4U1A=="

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
