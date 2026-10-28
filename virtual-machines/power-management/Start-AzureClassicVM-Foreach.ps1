
Add-AzureAccount
Get-AzureSubscription | Sort SubscriptionId | Select SubscriptionId
Select-AzureSubscription -SubscriptionId "XXXXXXXXXXXXXXXXX"

$CVMS = Get-AzureVM

foreach ($CVM in $CVMS)

    {
        $Powerstate = $CVM.Status

        if ($Powerstate -eq 'StoppedDeallocated')
            {

    Write-Output $CVM.Name
                Start-AzureVM -Name $CVM.Name -ServiceName $CVM.ServiceName
            }
    }

