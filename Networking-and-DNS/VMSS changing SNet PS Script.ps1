#Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId "<GUID>"

$RGName = "UserVMSS"
$VMSSName = "UserVMSS"
$Location = "southeastasia"
$VNetName = "UserVMSS-VNet"
$Subnet = "UserVMSS-SNet2"

$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RGName
$snet = Get-AzureRmVirtualNetworkSubnetConfig -Name $Subnet -VirtualNetwork $vnet

$snetid = $snet.Id

$VMSS = Get-AzureRmVmss -ResourceGroupName $RGName -VMScaleSetName $VMSSName

$vmss.VirtualMachineProfile.NetworkProfile.NetworkInterfaceConfigurations.IpConfigurations[0].Subnet = $snetid


Update-AzureRmVmss -ResourceGroupName $RGName -VMScaleSetName $VMSSName -VirtualMachineScaleSet $VMSS

Update-AzureRmVmssInstance -ResourceGroupName $RGName -VMScaleSetName $VMSSName -InstanceId "0","3" 

