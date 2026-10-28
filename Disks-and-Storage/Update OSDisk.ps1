$vm = Get-AzureRMVM -Name $VMName -ResourceGroupName $RGName
Stop-AzureRmVM -Name $VMName -ResourceGroupName $RGName -Force

$disk = Get-AzureRmDisk -ResourceGroupName $DiskRG -DiskName $DiskName

Set-AzVMOSDisk -VM $vm -ManagedDiskId $disk.Id -Name $disk.Name

Update-AzVM -ResourceGroupName $RGName -VM $vm
