Select-AzureRmProfile -Path C:\Users\gulab\Desktop\m4l.json

Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "G7CRM4L008"

$path = "c:\users\gulab\desktop\demo.csv"

Get-AzureRmRoleAssignment | Select-Object DisplayName, SignInName, RoleDefinitionName, Scope, ObjectType | Export-Csv -Path $path -Force

#Out-File -FilePath C:\Users\gulab\Desktop\Dummy3.csv -Force

