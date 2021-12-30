#Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "ss_ces_staging_csp"


$ResourceGroupName = "rgnusgvm"
$vmName = "ncuswinnode03"
$vmSize = "Standard D2s_v3"
$location = "North Central US"
$osDiskName = $vmName + "osDisk"

#Specify OSDISK (VHD) to creat your VM
$osDiskUri = "https://nussgvmssdgrs.blob.core.windows.net/"
$nicname = "$VMName-NIC"
$publicIPName = "$VMName-PIP"
$DNSName = $vmName.ToLower()

$subnetName = "nusstgsnet01"
$SNetAddr = "10.77.2.0/24"
$vnetName = "nusstgvnet01"
$VNetAddr = "10.77.0.0/16"


$singlesubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $SNetAddr
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $ResourceGroupName -Location $location -AddressPrefix $VNetAddr -Subnet $singlesubnet


$vnet = Get-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $ResourceGroupName
$SNet = Get-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet 

#Create Public IP and Network Card to Access your VM

#To Create Public IP
$pip = New-AzureRmPublicIpAddress -Name $publicIPName -ResourceGroupName $ResourceGroupName -Location $location `
-AllocationMethod Dynamic -DomainNameLabel $DNSName

#To Create NIC Card 
$nic = New-AzureRmNetworkInterface -Name $nicname -ResourceGroupName $ResourceGroupName -Location $location `
-SubnetId $SNet.Id -PublicIpAddressId $pip.Id


## Set Hardware/Software and Network config to your VM

$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

#Setup your VM with above config / profile

$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption attach -Windows -Caching ReadWrite

$vm

## Create the VM in Azure
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $location -VM $vm
