#Login-AzureRmAccount
#Save-AzureRmProfile -Path "C:\Users\user\Desktop\Text\Azure Scripts\user-contoso.com"
Select-AzureRmProfile -Path "C:\Users\user\Desktop\Text\Azure Scripts\gmail.json"

Get-AzureRmAutomationCredential -Name 'mycredentials' -ResourceGroupName 'AutoMation' -AutomationAccountName 'useruser'
AzureRM.Compute\Select-AzureRmSubscription -SubscriptionName 'Free Trial' -TenantId '<GUID>'
Get-AzureRmVM | Start-AzureRmVM