#Login-AzureRmAccount

$Subs = Get-AzureRmSubscription

$LockName = "Subex-IT-Lock"
$Des = "The lock is created by Subex IT Team"

Foreach ($Sub in $Subs)

{


Select-AzureRmSubscription -SubscriptionName $Sub.Name

$RSS = Get-AzureRmResource

Foreach ($RS in $RSS)

{


$RS.ResourceGroupName

New-AzureRmResourceLock -LockName $LockName -LockLevel CanNotDelete -LockNotes $Des -ResourceGroupName $RS.ResourceGroupName -Force


}

}