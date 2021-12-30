$StorageAccountName = "pocstgacc"
$StorageAccountKey = "1HNXVJ+EQgCUB3f9Ov158Rx0L2mmUUy7v5zYoxkHbUTYfpG3IjDqZ+l+c22mSBgOEPVpLRSZdhIGfFsVVdEj3g=="

$ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName `
         -StorageAccountKey $StorageAccountKey

$ContainerName = "test"

$localfiles =Get-ChildItem -Path "D:\testing\"

foreach($BlobName in $localfiles){

$blob = Get-AzureStorageBlob -Blob $BlobName -Container $ContainerName -Context $ctx -ErrorAction Ignore

if (-not $blob)
{
    Write-Host "Blob $BlobName Found"
    $BlobName | Set-AzureStorageBlobContent -Container $ContainerName -Context $ctx
}

}







