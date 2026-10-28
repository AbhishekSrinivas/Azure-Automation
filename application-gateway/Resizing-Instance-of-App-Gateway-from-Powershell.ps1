#Connect-AzureRmAccount

$AppGwExisting = Get-AzureRmApplicationGateway -Name "AG-instancecount" -ResourceGroupName "POC-RG"

$ExistingSku = $AppGwExisting.Sku

$ExistingSku

$AppGwUpdatedSku = Set-AzureRmApplicationGatewaySku -ApplicationGateway $AppGwExisting -Name WAF_Medium -Tier WAF -Capacity 2


$UpdatedAppGw = Set-AzureRmApplicationGateway -ApplicationGateway $AppGwExisting

$UpdatedAppGw.Sku


<#Set-AzureRmApplicationGatewaySku -ApplicationGateway $AppGwExisting

$SKU = New-AzureRmApplicationGatewaySku -Name "Standard_Small" -Tier "Standard" -Capacity 2 

Set-AzureRmApplicationGatewaySku
#>


