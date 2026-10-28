#Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId ""


$RGName = ""       
$VMName = "" 
$VMLocation = ""
$VMSize = ""
$DiskName = ""
#$VNetName = ""
#$SubnetName = ""
$NICName = ""
$Product = "postgresql"
$Name = "9-5"
$Publisher = "bitnami"

#$VNet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RGName

#$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VNet

$nic = Get-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $RGName 
                  
$disk = Get-AzureRmDisk -ResourceGroupName $RGName -DiskName $DiskName
       
$vm = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize

$agreementTerms = Get-AzureRmMarketplaceTerms -Publisher $Publisher -Product $Product -Name $Name | Set-AzureRmMarketplaceTerms -Accept
    
Set-AzureRmMarketplaceTerms -Publisher $Publisher -Product $Product -Name $Name -Terms $agreementTerms -Accept | Set-AzureRmMarketplaceTerms -Accept

$vm = Set-AzureRmVMPlan -VM $vm -Name $Name -Product $Product -Publisher $Publisher
      
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $DiskName -Linux -CreateOption "Attach" -ManagedDiskId $disk.Id      
   
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
        
New-AzureRmVM -VM $vm -ResourceGroupName $RGName -Location $VMLocation




