$RGName = 'LinuxRG'
$VmName = 'UbuntuVM'
$Location = 'Southeast Asia'

$ExtensionName = 'CustomScriptForLinux'
$Publisher = 'Microsoft.OSTCExtensions'
$Version = '1.4'

$PublicConf = '{
    "fileUris": ["https://<storage-account>.blob.core.windows.net/script/script.sh"],
    "commandToExecute": "sh script.sh"
}'
$PrivateConf = '{
    "storageAccountName": "subexlinuximagesstg",
    "storageAccountKey": "<STORAGE_ACCOUNT_KEY>"
}'

Set-AzureRmVMExtension -ResourceGroupName $RGName -VMName $VmName -Location $Location `
  -Name $ExtensionName -Publisher $Publisher `
  -ExtensionType $ExtensionName -TypeHandlerVersion $Version `
  -Settingstring $PublicConf -ProtectedSettingString $PrivateConf