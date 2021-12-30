#Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "Microsoft Azure"

$RGName = "PlantmisCert-RG"
$KeyVault = "plantmis-keyvault"
$user = "g7support@megatechcontrolpvtltd.onmicrosoft.com"


$key = Get-AzureRmKeyVault -ResourceGroupName $RGName -VaultName $KeyVault 

Set-AzureRmKeyVaultAccessPolicy -VaultName $KeyVault -ResourceGroupName $RGName -UserPrincipalName $user -PermissionsToKeys list,Get -PermissionsToSecrets list,Get -PermissionsToCertificates list,get

$ascResource = Get-AzureRmResource -ResourceName plantmisCert -ResourceGroupName PlantmisCert-RG -ResourceType "Microsoft.CertificateRegistration/certificateOrders" -ApiVersion "2015-08-01"
$keyVaultId = "psshowvault"
$keyVaultSecretName = "Barn980use367@"

$certificateProperties=Get-Member -InputObject $ascResource.Properties.certificates[0] -MemberType NoteProperty
$certificateName = $certificateProperties[0].Name
$keyVaultId = $ascResource.Properties.certificates[0].$certificateName.KeyVaultId
$keyVaultSecretName = $ascResource.Properties.certificates[0].$certificateName.KeyVaultSecretName


$keyVaultIdParts = $keyVaultId.Split("/")
$keyVaultName = $keyVaultIdParts[$keyVaultIdParts.Length - 1]
$keyVaultResourceGroupName = $keyVaultIdParts[$keyVaultIdParts.Length - 5]
Set-AzureRmKeyVaultAccessPolicy -ResourceGroupName $RGName -VaultName $KeyVault -UserPrincipalName $user -PermissionsToSecrets get,list
$secret = Get-AzureKeyVaultSecret -VaultName $keyVaultName -Name $keyVaultSecretName
$pfxCertObject=New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @([Convert]::FromBase64String($secret.SecretValueText),"", [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
$pfxPassword = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 50 | % {[char]$_})
$currentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
[Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath
[io.file]::WriteAllBytes(".\appservicecertificate.pfx", $pfxCertObject.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $pfxPassword))
Write-Host "Created an App Service Certificate copy at: $currentDirectory\appservicecertificate.pfx"
Write-Warning "For security reasons, do not store the PFX password. Use it directly from the console as required."
Write-Host "PFX password: $pfxPassword" 
