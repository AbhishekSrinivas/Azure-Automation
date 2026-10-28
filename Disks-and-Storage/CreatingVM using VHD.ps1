Login-AzureRmAccount

## Global Variables 
$ResourceGroupName = "contoso00s2"
$location = "centralindia"
$storageType = "Standard_DS1_V2"


## Network
$nicname = "contoso00s2"
$subnetName = "contoso00s2"
$vnetName = "contoso00s2"
$vnetAddressPrefix = "10.0.0.0/16"
$vnetSubnetAddressPrefix = "10.0.0.0/24"
$publicIPName = "contoso00s2"

## Compute
$vmName = "contoso00s2"
$computerName = "contoso00s2"
$vmSize = "Standard_DS1_V2"
$osDiskName = $vmName + "osDisk"

#The password must be at 12-123 characters long and have at least one lower case character, one upper case character, one number, and one special character. 
$adminUsername = 'labadmin'
$adminPassword = '<PASSWORD>'	

#Create New Os Disk uri
$osDiskUri = "https://<storage-account>.blob.core.windows.net/osdisk/contoso00s2.vhd"

#Image URI you can Find Storage group --> Blob --> System -->Microsoft.Compute -->Images --> your conntainer Name --> vhd name given while caputure VM.
$imageUri = "https://<storage-account>.blob.core.windows.net/vhds/contoso00s220170622151912.vhd"

#Create New Resouce Group
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $location


#Create a virtual network
$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $vnetSubnetAddressPrefix
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $ResourceGroupName -Location $location -AddressPrefix $vnetAddressPrefix -Subnet $singleSubnet

#Create a public IP address and network interface
$pip = New-AzureRmPublicIpAddress -Name $publicIPName -ResourceGroupName $ResourceGroupName -Location $location -AllocationMethod Dynamic
$nic = New-AzureRmNetworkInterface -Name $nicname -ResourceGroupName $ResourceGroupName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id


#Create a virtual machine

#The password must be at 12-123 characters long and have at least one lower case character, one upper case character, one number, and one special character. 

$cred = New-Object PSCredential $adminUsername, ($adminPassword | ConvertTo-SecureString -AsPlainText -Force)

$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $computerName -Credential $cred

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption FromImage -SourceImageUri $imageUri  -Caching ReadWrite -Windows

$vm = Set-AzureRmVMBootDiagnostics -VM $vm -Disable

#running below command you can see your VM attached parameters.
$vm

#Create the new VM
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $location -VM $vm

