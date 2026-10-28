
Select-AzureRmSubscription -SubscriptionId <GUID>


# Get Azure Application Gateway
$appgw=Get-AzApplicationGateway -Name AGW-fkexchangeStagenew -ResourceGroupName RG-fkexchangeStageNew

Start-AzApplicationGateway -ApplicationGateway $appgw

# Stop the Azure Application Gateway
#Stop-AzApplicationGateway -ApplicationGateway $appgw
# Start the Azure Application Gateway (optional)
 
