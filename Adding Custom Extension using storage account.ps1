$RGName = 'LinuxRG'
$VmName = 'UbuntuVM'
$Location = 'Southeast Asia'

$ExtensionName = 'CustomScriptForLinux'
$Publisher = 'Microsoft.OSTCExtensions'
$Version = '1.4'

$PublicConf = '{
    "fileUris": ["https://subexlinuximagesstg.blob.core.windows.net/script/script.sh"],
    "commandToExecute": "sh script.sh"
}'
$PrivateConf = '{
    "storageAccountName": "subexlinuximagesstg",
    "storageAccountKey": "L1cTjXGb6aMtkVrPCkIGmCWCIGXqSreCYOaQ37g2akb7R+H6rLrABynNZpcahYJo5XAmakYDL3oIVYz3NtAJNA=="
}'

Set-AzureRmVMExtension -ResourceGroupName $RGName -VMName $VmName -Location $Location `
  -Name $ExtensionName -Publisher $Publisher `
  -ExtensionType $ExtensionName -TypeHandlerVersion $Version `
  -Settingstring $PublicConf -ProtectedSettingString $PrivateConf