$StorageAccountName = "pocstgacc"
$StorageAccountKey = <STORAGE_ACCOUNT_KEY>

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







