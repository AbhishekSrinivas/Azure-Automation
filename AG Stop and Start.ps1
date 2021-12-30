
Select-AzureRmSubscription -SubscriptionId 6f6fcdbf-b559-431b-a2b6-6e1b5fd68fcb


# Get Azure Application Gateway
$appgw=Get-AzApplicationGateway -Name AGW-fkexchangeStagenew -ResourceGroupName RG-fkexchangeStageNew

Start-AzApplicationGateway -ApplicationGateway $appgw

# Stop the Azure Application Gateway
#Stop-AzApplicationGateway -ApplicationGateway $appgw
# Start the Azure Application Gateway (optional)
 
