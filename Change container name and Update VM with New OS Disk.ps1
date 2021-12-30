Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId "ed7cbbe3-82d4-433f-8fc9-930ecaaae190"


$ResourceGroup = 'rgsisgvm'
$VMname = 'pcindwinnode05'

$VM = Get-AzureRmVM -Name $VMname -ResourceGroupName $ResourceGroup


Stop-AzureRmVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Force


$VM.StorageProfile.OsDisk.Vhd.Uri = 'https://sisgvmssdgrs.blob.core.windows.net/vhds/PCINDWINNODE0520180124145941.vhd'


Update-AzureRmVM -VM $VM -ResourceGroupName $ResourceGroup

Start-AzureRMVM -Name $VMname -ResourceGroupName $ResourceGroup
