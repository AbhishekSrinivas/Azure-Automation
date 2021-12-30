#Login-AzureRmAccount

Select-AzureRmSubscription -Subscription "G7CRM4L007"


$VMName = "SonaliDVM"
$VMLocation = "Central India"
$VMSize = "Basic_A0"
$VNet_Add = "10.0.0.0/16"
$Subnet_Add = "10.0.0.0/24"
$Username = "labadmin"
$Password = "P@ssw0rd@123"

$DiskRGName = "Image-RG"
$DiskName = "DemoManagedD_disk1_68f2d94ed85844b8b8dc44ba1c44d8c4"

New-AzureRmResourceGroup -Name $VMName -Location $VMLocation -Force

$subnet = New-AzureRmVirtualNetworkSubnetConfig -Name "$VMName-Subnet" -AddressPrefix $Subnet_Add
$vnet = New-AzureRmVirtualNetwork -Name "$VMName-VNet" -ResourceGroupName $VMName -Location $VMLocation `
-AddressPrefix $VNet_Add -Subnet $subnet -Force

$pip = New-AzureRmPublicIpAddress -Name "$VMName-PIP" -ResourceGroupName $VMName -Location $VMLocation `
-AllocationMethod Dynamic -DomainNameLabel $VMName.ToLower() -Force

$nic = New-AzureRmNetworkInterface -Name "$VMName-NIC" -ResourceGroupName $VMName -Location $VMLocation `
-SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -Force


$ManagedDisk = Get-AzureRmDisk -ResourceGroupName $RGName -DiskName $DiskName


$cred = New-Object PSCredential $Username, ($Password | ConvertTo-SecureString -AsPlainText -Force)


$diskConfig = New-AzureRmDiskConfig -AccountType StandardLRS -Location $VMLocation -SourceResourceId $ManagedDisk.Id -CreateOption Copy
 
New-AzureRmDisk -Disk $diskConfig -ResourceGroupName $VMName -DiskName "$VMName-OSDISK"
        
$disk = Get-AzureRmDisk -DiskName "$VMName-OSDISK" -ResourceGroupName $VMName


$vm = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize

$vm = Set-AzureRmVMOSDisk -VM $vm -ManagedDiskId $disk.Id -Caching ReadWrite -CreateOption Attach -Linux

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

$vm = Set-AzureRmVMBootDiagnostics -VM $vm -Disable

New-AzureRmVM -VM $vm -ResourceGroupName $VMName -Location $VMLocation