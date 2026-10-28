Select-AzureRmProfile -Path C:\Users\user\Desktop\contoso.json

Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "ContosoContoso008"

$path = "c:\users\user\desktop\demo.csv"

Get-AzureRmRoleAssignment | Select-Object DisplayName, SignInName, RoleDefinitionName, Scope, ObjectType | Export-Csv -Path $path -Force

#Out-File -FilePath C:\Users\user\Desktop\Dummy3.csv -Force

