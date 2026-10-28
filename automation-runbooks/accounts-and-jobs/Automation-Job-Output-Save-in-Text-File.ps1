Select-AzureRmProfile -Path C:\Users\adm_user\Desktop\ContosoContoso.json

Select-AzureRmSubscription -SubscriptionName "ContosoContosoS001"


$RGName = "ContosoAutomation"
$AutoAcc = "ContosoAutomationAC"
$WRBName = "CreateVM-Windows"
$LRBName = "CreateVM-Linux"
$inc =     "****************************************** Next Job ***************************************************************"
$incnewj = "************************************** New Job Starts Here ********************************************************"

$gjob = Get-AzureRmAutomationJob -RunbookName $WRBName -ResourceGroupName $RGName -AutomationAccountName $AutoAcc

Foreach ($jobid in $gjob.JobId)


{$output = Get-AzureRmAutomationJobOutput -Id $jobid -ResourceGroupName $RGName -AutomationAccountName $AutoAcc `
-Stream Output

$output.Summary + "`n $inc","`n","`n","`n","`n $incnewj" | Add-Content -Path C:\users\adm_user\Desktop\JobOutPut\CreateVM-Windows.txt

}

