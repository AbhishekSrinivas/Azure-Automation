#Login-AzureRmAccount
#Save-AzureRmProfile -Path "C:\Users\gulab\Desktop\Text\Azure Scripts\gulab-g7cr.json"
Select-AzureRmProfile -Path "C:\Users\gulab\Desktop\Text\Azure Scripts\gmail.json"

Get-AzureRmAutomationCredential -Name 'mycredentials' -ResourceGroupName 'AutoMation' -AutomationAccountName 'gulabpasha'
AzureRM.Compute\Select-AzureRmSubscription -SubscriptionName 'Free Trial' -TenantId '493b9b55-2210-462f-ac55-0813e61f7e86'
Get-AzureRmVM | Start-AzureRmVM