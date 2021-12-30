Login-AzureRmAccount
New-AzureRmResourceGroup -Name "AutoMation-Demo" -Location 'southeastasia'
New-AzureRmAutomationAccount -Name 'gulabpasha' -ResourceGroupName "AutoMation-Demo" -Location 'southeastasia'
New-AzureRmAutomationCredential -AutomationAccountName 'gulabpasha' -Name 'mycredentials' -ResourceGroupName 'AutoMation-Demo'

#New-AzureRmAutomationRunbook -Name 'Start-VMs' -AutomationAccountName gulabpasha -ResourceGroupName 'AutoMation-Demo-VMs' -Type PowerShell


#Import-AzureRmAutomationRunbook -AutomationAccountName gulabpasha -ResourceGroupName AutoMation-Demo -Path "C:\Users\gulab\Desktop\Text\AutoMation Run Books\SendMailO365-MS-Mgmt.graphrunbook" -Type GraphicalPowerShellWorkflow
#Import-AzureRmAutomationRunbook -AutomationAccountName gulabpasha -ResourceGroupName AutoMation-Demo -Path "C:\Users\gulab\Desktop\Text\AutoMation Run Books\CleanSolution-MS-Mgmt-VM.ps1" -Type PowerShell
#Import-AzureRmAutomationRunbook -AutomationAccountName gulabpasha -ResourceGroupName AutoMation-Demo -Path "C:\Users\gulab\Desktop\Text\AutoMation Run Books\StartByResourceGroup-MS-Mgmt-VM.ps1" -Type PowerShell
#Import-AzureRmAutomationRunbook -AutomationAccountName gulabpasha -ResourceGroupName AutoMation-Demo -Path "C:\Users\gulab\Desktop\Text\AutoMation Run Books\StopByResourceGroup-MS-Mgmt-VM.ps1" -Type PowerShell

#Publish-AzureRmAutomationRunbook -ResourceGroupName AutoMation-Demo -AutomationAccountName gulabpasha -Name SendMailO365-MS-Mgmt 
#Publish-AzureRmAutomationRunbook -Name CleanSolution-MS-Mgmt-VM -ResourceGroupName AutoMation-Demo -AutomationAccountName gulabpasha
#Publish-AzureRmAutomationRunbook -Name StartByResourceGroup-MS-Mgmt-VM -ResourceGroupName AutoMation-Demo -AutomationAccountName gulabpasha
#Publish-AzureRmAutomationRunbook -Name StopByResourceGroup-MS-Mgmt-VM -ResourceGroupName AutoMation-Demo -AutomationAccountName gulabpasha

New-AzureRmAutomationSchedule -Name Start-VM -StartTime "11/11/2016 8:45:00" -DayInterval 1 -TimeZone "IST" -ResourceGroupName "AutoMation-Demo" -AutomationAccountName "gulabpasha"


Register-AzureRmAutomationScheduledRunbook -RunbookName "StartByResourceGroup-MS-Mgmt-VM" -ScheduleName "Start-AzureRmVM" -AutomationAccountName "gulabpasha" -ResourceGroupName "AutoMation-Demo" -Parameters "Default:Azure"
Register-AzureRmAutomationScheduledRunbook -RunbookName "StopByResourceGroup-MS-Mgmt-VM" -ScheduleName "Stop-AzureRmVM" -AutomationAccountName "gulabpasha" -ResourceGroupName "AutoMation-Demo" -Parameters "Default:Azure"


