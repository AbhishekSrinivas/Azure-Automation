Select-AzureRmProfile -Path C:\Users\adm_gulab\Desktop\AlchemyM4L.json

Select-AzureRmSubscription -SubscriptionName "G7CRM4LS001"


$RGName = "M4LAutomation"
$AutoAcc = "M4LAutomationAC"
$WRBName = "CreateVM-Windows"
$LRBName = "CreateVM-Linux"
$inc =     "****************************************** Next Job ***************************************************************"
$incnewj = "************************************** New Job Starts Here ********************************************************"

$gjob = Get-AzureRmAutomationJob -RunbookName $WRBName -ResourceGroupName $RGName -AutomationAccountName $AutoAcc

Foreach ($jobid in $gjob.JobId)


{$output = Get-AzureRmAutomationJobOutput -Id $jobid -ResourceGroupName $RGName -AutomationAccountName $AutoAcc `
-Stream Output

$output.Summary + "`n $inc","`n","`n","`n","`n $incnewj" | Add-Content -Path C:\users\adm_gulab\Desktop\JobOutPut\CreateVM-Windows.txt

}

