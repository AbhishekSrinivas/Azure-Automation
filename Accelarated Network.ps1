#Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "Visual Studio Enterprise – MPN"

$RGName = "SQLVMRG"
$NICName = "sqlvm928"

$NIC = Get-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $RGName

$NIC.Name

$NIC.EnableAcceleratedNetworking



$NIC.EnableAcceleratedNetworking = $false

Set-AzureRmNetworkInterface -NetworkInterface $NIC

