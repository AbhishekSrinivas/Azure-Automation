Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "INDIA-TB"

$Location = "Central India"
$VMName = "NikshayProd"
$RGName = "Nikshay-DB-RG"
 
Get-AzureRmVMUsage -Location $Location


$vm = Get-AzureRMVM -Name $VMName -ResourceGroupName $RGName

$vm.HardwareProfile.VmSize = "Standard_E20S_v3"

Stop-AzureRmVM -Name $VMName -ResourceGroupName $RGName -Force


Update-AzureRmVM -ResourceGroupName $RGName -VM $vm 

Start-AzureRMVM -Name $VMName -ResourceGroupName $RGName