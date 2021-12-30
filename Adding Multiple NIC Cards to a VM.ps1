
Select-AzureRmSubscription -Subscription "8d9f3d45-2cc3-4096-83a6-a559f5e68e1a"

$RGName = "AirPay-VMs-RG"
$VMName = "Monitor-Airpay"
$NSGName = "Ac-Airpay-nsg"
$NewNICName= "monitor-airpay202"

$VNetRG = "AirPay-Site2Site-RG"
$VNetName = "AirPay-VNET"
$SubnetName = "Staging-Snet2-AZ1"

Stop-AzureRmVM -Name $VMName -ResourceGroupName $RGName -Force

$VM = Get-AzureRmVM -ResourceGroupName $RGName -Name $VMName

$vm.NetworkProfile.NetworkInterfaces

$vm.NetworkProfile.NetworkInterfaces[0].Primary = $true
Update-AzureRmVM -VM $vm -ResourceGroupName $RGName



$nsg = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $RGName
$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $VNetRG
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet


New-AzureRmNetworkInterface -Name $NewNICName -ResourceGroupName $RGName -Location $vm.Location -SubnetId $subnet.Id -NetworkSecurityGroupId $nsg.Id

$NewNIC = (Get-AzureRmNetworkInterface -ResourceGroupName $RGName -Name $NewNICName).Id
Add-AzureRmVMNetworkInterface -VM $vm -Id $NewNIC | Update-AzureRmVm -ResourceGroupName $RGName

Start-AzureRmVM -Name $VMName -ResourceGroupName $RGName

