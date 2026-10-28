

$RGName = "AppGW-Scale"
$appGW = "appGW"
$SKUCount = "4"
$SKUName = "WAF_Medium"
$Tier = "WAF"

$Gatway = Get-AzureRmApplicationGateway -ResourceGroupName $RGName -Name $appGW

$Gatway = Set-AzureRmApplicationGatewaySku -ApplicationGateway $Gatway -Name $SKUName -Tier $Tier -Capacity $SKUCount | New-AzureRmApplicationGateway

