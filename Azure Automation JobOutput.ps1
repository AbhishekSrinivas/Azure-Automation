Select-AzureRmProfile -Path C:\Users\adm_gulab\Desktop\AlchemyM4L.json
#Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName "G7CRM4LS001"

$RGName = "M4LAutomation"
$AutoAcc = "M4LAutomationAC"
$RBLinux = "CreateVM-Linux"
$RBWindows = "CreateVM-Windows"
$RBWScheduler = "CVM_DRG-Scheduler-Windows"
$RBLScheduler = "CVM_DRG-Scheduler-Linux"

$gjob = Get-AzureRmAutomationJob -RunbookName $RBLinux -ResourceGroupName $RGName -AutomationAccountName $AutoAcc


Foreach ($jobid in $gjob.JobId)

{
$output = Get-AzureRmAutomationJobOutput -Id $jobid -ResourceGroupName $RGName -AutomationAccountName $AutoAcc `
-Stream Output -StartTime "07-04-2017 05:00 AM" 

$output.summary | Add-Content -Path C:\Users\adm_gulab\Desktop\JobOutPut\CreateVM-Linux.txt

}

