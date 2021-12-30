Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId "212c8164-b331-44f3-9432-437a8a27edf6"

$Files = Import-Csv -Path "C:\Users\Gulab\Desktop\Book1.csv"

$RGName = "GulabAPGWRG"
$AppGWName = "GulabApGW"

$AppGW = Get-AzureRMApplicationGateway -Name $AppGWName -ResourceGroupName $RGName 
$fconfig = Get-AzureRMApplicationGatewayFrontendIPConfig -Name $AppGW.FrontendIPConfigurations.Name[0] -ApplicationGateway $AppGW
$fport = Get-AzureRMApplicationGatewayFrontendPort -Name $AppGW.FrontendPorts.Name -ApplicationGateway $AppGW
$bpool = Get-AzureRMApplicationGatewayBackendAddressPool -Name $AppGW.BackendAddressPools.Name -ApplicationGateway $AppGW


Foreach ($File in $Files)

{

Add-AzureRMApplicationGatewayProbeConfig -ApplicationGateway $AppGW -Name $File.HLProbeName -Protocol Http -HostName $File.HLProbeHostName -Path "/" `
-Interval "30" -Timeout "30" -UnhealthyThreshold "3"

        $HL = Get-AzureRmApplicationGatewayProbeConfig -ApplicationGateway $AppGW -Name $File.HLProbeName

 
Add-AzureRMApplicationGatewayBackendHttpSettings -ApplicationGateway $AppGW -Name $File.HTTPSettingName -Port 80 `
-Protocol Http -CookieBasedAffinity Enabled -RequestTimeout "30" -HostName $File.HTTPSettingHost -ProbeId $HL.Id

        $bhttp = Get-AzureRmApplicationGatewayBackendHttpSettings -Name $File.HTTPSettingName -ApplicationGateway $AppGW

 
Add-AzureRMApplicationGatewayHttpListener -ApplicationGateway $AppGW -Name $File.HTTPListenerName -FrontendIPConfiguration $fconfig `
-Protocol Http -HostName $File.HTTPSettingHost -FrontendPort $fport


        $ls = Get-AzureRmApplicationGatewayHttpListener -Name $File.HTTPListenerName -ApplicationGateway $AppGW


Add-AzureRmApplicationGatewayRequestRoutingRule -ApplicationGateway $AppGW -Name $File.HTTPRuleName -RuleType Basic -HttpListener $ls -BackendAddressPool $bpool `
-BackendHttpSettings $bhttp

}

Set-AzureRMApplicationGateway -ApplicationGateway $AppGW

 