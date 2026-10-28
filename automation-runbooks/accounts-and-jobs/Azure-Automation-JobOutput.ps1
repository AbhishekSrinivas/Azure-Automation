Select-AzureRmProfile -Path C:\Users\adm_user\Desktop\ContosoContoso.json
#Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName "ContosoContosoS001"

$RGName = "ContosoAutomation"
$AutoAcc = "ContosoAutomationAC"
$RBLinux = "CreateVM-Linux"
$RBWindows = "CreateVM-Windows"
$RBWScheduler = "CVM_DRG-Scheduler-Windows"
$RBLScheduler = "CVM_DRG-Scheduler-Linux"

$gjob = Get-AzureRmAutomationJob -RunbookName $RBLinux -ResourceGroupName $RGName -AutomationAccountName $AutoAcc


Foreach ($jobid in $gjob.JobId)

{
$output = Get-AzureRmAutomationJobOutput -Id $jobid -ResourceGroupName $RGName -AutomationAccountName $AutoAcc `
-Stream Output -StartTime "07-04-2017 05:00 AM" 

$output.summary | Add-Content -Path C:\Users\adm_user\Desktop\JobOutPut\CreateVM-Linux.txt

}

