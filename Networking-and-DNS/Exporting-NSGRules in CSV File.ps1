# Sign-in with Azure account credentials
#Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "ContosoTadam"

$RGName = "<resource-group>"
$NSGName = "<nsg-name>"

$NSG = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $RGName

$NSGRules = Get-AzureRmNetworkSecurityRuleConfig -NetworkSecurityGroup $NSG

$file = "C:\Users\user\Desktop\Tadam_NSGRules.csv"

$results = @()

Foreach ($NSGRule in $NSGRules)

{


$details  = @{ 

"Direction" = $NSGRule.Direction
"NSGRule_Name" = $NSGRule.Name
"SourcePortRange" = $NSGRule.SourcePortRange[0]
"Destination_Port_Range" = $NSGRule.DestinationPortRange[0]
"SourceAddressPrefix" = $NSGRule.SourceAddressPrefix[0]
"DestinationAddressPrefix" = $NSGRule.DestinationAddressPrefix[0]
"Access" = $NSGRule.Access
"Priority" = $NSGRule.Priority
"Protocol" = $NSGRule.Protocol

 }

$results += New-Object PSObject -Property $details
}

$results | Select "Direction","NSGRule_Name","SourcePortRange","Destination_Port_Range","SourceAddressPrefix","DestinationAddressPrefix","Access","Priority","Protocol" | Export-Csv -Path $file
