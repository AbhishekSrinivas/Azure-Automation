#Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName ""


Get-AzureRmComputeResourceSku | where {$_.Locations -icontains "northcentralus"}

