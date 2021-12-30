Select-AzureRmProfile -Path C:\Users\gulab\Desktop\Nusrath.json

$SubscriptionName = Get-AzureRmSubscription | sort SubscriptionName | Select SubscriptionName

$SubscriptionName = $SubscriptionName.SubscriptionName 

Select-AzureRmSubscription -SubscriptionName $SubscriptionName 

$LBRGName = "DemoLoadBalancer03"
$LBLoc = "SouthIndia"
$LBSubnet = "LB-Subnet"
$LBVNet = 'LB-VNet'
$LBPIP = 'LB-PIP'
$LBFPIP = 'PublicIP'
$LBDNSLable = 'demoloadbalancer2'


New-AzureRmResourceGroup -Name $LBRGName -Location $LBLoc

# 1. Create a subnet and a virtual network.

$backendSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $LBSubnet -AddressPrefix 10.0.2.0/24

New-AzureRmvirtualNetwork -Name $LBVNet -ResourceGroupName $LBRGName -Location $LBLoc -AddressPrefix 10.0.0.0/16 -Subnet $backendSubnet


# 2. Create an Azure public IP address resource, named PublicIP, to be used by a front-end IP pool with the DNS name loadbalancernrp.
    #westus.cloudapp.azure.com. The following command uses the static allocation type.

 $publicIP = New-AzureRmPublicIpAddress -Name $LBPIP -ResourceGroupName $LBRGName -Location $LBLoc -AllocationMethod Static -DomainNameLabel $LBDNSLable

 
# 3. Create a front-end IP pool named LB-Frontend that uses the PublicIp resource.

 $frontendIP = New-AzureRmLoadBalancerFrontendIpConfig -Name LB-Frontend -PublicIpAddress $publicIP


# 4. Create a back-end address pool named LB-backend.

 $beaddresspool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name LB-backend


# 5. Create the NAT rules.

 $inboundNATRule1= New-AzureRmLoadBalancerInboundNatRuleConfig -Name ssh1 -FrontendIpConfiguration $frontendIP -Protocol TCP -FrontendPort 2200 -BackendPort 22

 $inboundNATRule2= New-AzureRmLoadBalancerInboundNatRuleConfig -Name ssh2 -FrontendIpConfiguration $frontendIP -Protocol TCP -FrontendPort 2201 -BackendPort 22

 $inboundNATRule3= New-AzureRmLoadBalancerInboundNatRuleConfig -Name ssh3 -FrontendIpConfiguration $frontendIP -Protocol TCP -FrontendPort 2202 -BackendPort 22


# 6. Create a health probe. There are two ways to configure a probe:

 $healthProbe = New-AzureRmLoadBalancerProbeConfig -Name HealthProbe -RequestPath 'HealthProbe.aspx' -Protocol http -Port 80 -IntervalInSeconds 15 -ProbeCount 2


# a) TCP probe

 $healthProbe = New-AzureRmLoadBalancerProbeConfig -Name HealthProbe -Protocol Tcp -Port 80 -IntervalInSeconds 15 -ProbeCount 2


# 7. Create a load balancer rule.

 $lbrule = New-AzureRmLoadBalancerRuleConfig -Name HTTP -FrontendIpConfiguration $frontendIP -BackendAddressPool  $beAddressPool `
           -Probe $healthProbe -Protocol Tcp -FrontendPort 80 -BackendPort 80


# 8. Create the load balancer by using the previously created objects.

 $NRPLB = New-AzureRmLoadBalancer -ResourceGroupName $LBRGName -Name NRP-LB -Location $LBLoc -FrontendIpConfiguration $frontendIP `
          -InboundNatRule $inboundNATRule1,$inboundNatRule2,$inboundNATRule3 -LoadBalancingRule $lbrule -BackendAddressPool $beAddressPool -Probe $healthProbe


