#Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "Azure Pass - Sponsorship"

$RGName = "Applicationserver-RG"
$NICName = "applicationserver285"

$NIC = Get-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $RGName

$NIC.Name

$NIC.EnableAcceleratedNetworking



$NIC.EnableAcceleratedNetworking = $True

Set-AzureRmNetworkInterface -NetworkInterface $NIC


