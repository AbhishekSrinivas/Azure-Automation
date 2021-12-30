Login-AzureRmAccount

$Tenant = Get-AzureRmSubscription

Connect-AzureAD -TenantId $Tenant.TenantId

$AppName = "gulabapp"
$AppURI = "https://gulabapp.com"
$ServicePName = "GulabApp"


$azureAdApplication = New-AzureRmADApplication -DisplayName $AppName -HomePage $AppURI -IdentifierUris $AppURI

$svcprincipal = New-AzureRmADServicePrincipal -ApplicationId $azureAdApplication.ApplicationId -DisplayName $ServicePName

$azureAdApp = Get-AzureRmADApplication -ApplicationId $azureAdApplication.ApplicationId

$azureAdServicePrincpal = Get-AzureRmADServicePrincipal -SearchString $azureAdApp.DisplayName

$startDate = Get-Date
$endDate = $startDate.AddYears(10)
$aadAppKeyPwd = New-AzureADApplicationPasswordCredential -ObjectId $azureAdApplication.ObjectId -CustomKeyIdentifier "Primary" -StartDate $startDate -EndDate $endDate


sleep -Seconds "10"

$roleassignment = New-AzureRmRoleAssignment -RoleDefinitionName "Owner" -ServicePrincipalName $azureAdApplication.ApplicationId.Guid

# Display the values for your application 

Write-Output "Tenant ID:" (Get-AzureRmContext).Tenant.TenantId | Out-File -FilePath C:\Users\Gulab\Desktop\Gulab.txt
Write-Output "Application ID:" $azureAdApplication.ApplicationId.Guid | Add-Content -Path C:\Users\Gulab\Desktop\Gulab.txt
Write-Output "Application Name:" $azureAdApplication.DisplayName | Add-Content -Path C:\Users\Gulab\Desktop\Gulab.txt
Write-Output "Service Principal Name:" $azureAdServicePrincpal.DisplayName | Add-Content -Path C:\Users\Gulab\Desktop\Gulab.txt
Write-Output "Service Principal Key" $aadAppKeyPwd.Value | Add-Content -Path C:\Users\Gulab\Desktop\Gulab.txt



