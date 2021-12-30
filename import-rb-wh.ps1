#Select-AzureRmProfile -path C:\Users\gulab\Desktop\m4l.json
Login-AzureRmAccount
#Select-AzureRmSubscription -SubscriptionName DevTest_MAS

$RGName = "M4LAutomation"
$AutoAcc = "support"
$Loc = "CentralIndia"

$RbStartVM = "StartVM-WH"
$RBStopVM = "StopVM-WH"
$RBStopVMSQL = "StopVM-SQL"
$RBRemoveVM = "RemoveRG-WH"
$M4LSajid = "M4LProcessPendingEmail"
$CreateVM = "CreateVM"
$DestroyVM = "DestroyVM"
$SchVM = "Scheduler-WH"

$path1 = 'C:\Users\gulab\Desktop\RunBook-Final\Import\StartVM-WH.ps1'
$path2 = 'C:\Users\gulab\Desktop\RunBook-Final\Import\StopVM-WH.ps1'
$path3 = 'C:\Users\gulab\Desktop\RunBook-Final\Import\StopVM-SQL.ps1'
$path4 = 'C:\Users\gulab\Desktop\RunBook-Final\Import\RemoveRG-WH.ps1'
$path5 = 'C:\Users\gulab\Desktop\RunBook-Final\Import\M4LProcessPendingEmail.ps1'
$path6 = 'C:\Users\gulab\Desktop\RunBook-Final\Import\CreateVM.ps1'
$path7 = 'C:\Users\gulab\Desktop\RunBook-Final\Import\DestroyVM.ps1'
$path8 = 'C:\Users\gulab\Desktop\RunBook-Final\Import\Scheduler-WH.ps1'


Import-AzureRmAutomationRunbook -Path $path1 -Name $RbStartVM -ResourceGroupName $RGName `
-AutomationAccountName $AutoAcc -Published -Force -Type PowerShellWorkflow -LogProgress $True -LogVerbose $True

Import-AzureRmAutomationRunbook -Path $path2 -Name $RBStopVM -ResourceGroupName $RGName `
-AutomationAccountName $AutoAcc -Published -Force -Type PowerShellWorkflow -LogProgress $True -LogVerbose $True

Import-AzureRmAutomationRunbook -Path $path3 -Name $RBStopVMSQL -ResourceGroupName $RGName `
-AutomationAccountName $AutoAcc -Published -Force -Type PowerShellWorkflow -LogProgress $True -LogVerbose $True

Import-AzureRmAutomationRunbook -Path $path4 -Name $RBRemoveVM -ResourceGroupName $RGName `
-AutomationAccountName $AutoAcc -Published -Force -Type PowerShellWorkflow -LogProgress $True -LogVerbose $True

Import-AzureRmAutomationRunbook -Path $path5 -Name $M4LSajid -ResourceGroupName $RGName `
-AutomationAccountName $AutoAcc -Published -Force -Type PowerShell -LogProgress $True -LogVerbose $True

Import-AzureRmAutomationRunbook -Path $path6 -Name $CreateVM -ResourceGroupName $RGName `
-AutomationAccountName $AutoAcc -Published -Force -Type PowerShellWorkflow -LogProgress $True -LogVerbose $True

Import-AzureRmAutomationRunbook -Path $path7 -Name $DestroyVM -ResourceGroupName $RGName `
-AutomationAccountName $AutoAcc -Published -Force -Type PowerShellWorkflow -LogProgress $True -LogVerbose $True

Import-AzureRmAutomationRunbook -Path $path8 -Name $SchVM -ResourceGroupName $RGName `
-AutomationAccountName $AutoAcc -Published -Force -Type PowerShellWorkflow -LogProgress $True -LogVerbose $True


$WHURI1 = New-AzureRmAutomationWebhook -Name $RbStartVM -RunbookName $RbStartVM -ResourceGroupName $RGName `
-AutomationAccountName $AutoAcc -ExpiryTime "01/31/2022 10:00:00 AM" -IsEnabled $True -Force

$WHURI1.WebhookURI

$WHURI2 = New-AzureRmAutomationWebhook -Name $RBStopVM -RunbookName $RBStopVM -ResourceGroupName $RGName `
-AutomationAccountName $AutoAcc -IsEnabled $True -ExpiryTime "01/31/2022 10:00:00 AM" -Force

$WHURI2.WebhookURI

$WHURI3 = New-AzureRmAutomationWebhook -Name $RBRemoveVM -RunbookName $RBRemoveVM -ResourceGroupName $RGName `
-AutomationAccountName $AutoAcc -IsEnabled $True -ExpiryTime "01/31/2022 10:00:00 AM" -Force

$WHURI3.WebhookURI

$WHURI4 = New-AzureRmAutomationWebhook -Name $SchVM -RunbookName $SchVM -ResourceGroupName $RGName `
-AutomationAccountName $AutoAcc -IsEnabled $True -ExpiryTime "01/31/2022 10:00:00 AM" -Force

$WHURI4.WebhookURI
