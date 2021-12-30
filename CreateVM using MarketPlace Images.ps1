Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName 'G7CRM4L008'

$location = “SouthIndia”
$rgroup = “LinuxdemoVM01”
$storage = "linuxdemovmstg01" 
$containerName = "linuxdemovmvhd"
$vmname = “LinuxdemoVM01”
$vmSize = "Standard_D2_V2"
$computerName = "LinuxdemoVM01"
$osDiskName = $vmname + "-OSDisk"
$nic = $vmname + "-nic"
$vnetname= $vmname + "-vnet"
$subnetname =  $vmname + "-Subnet"
$vnetAddressPrefix = "10.0.0.0/16"
$vnetSubnetAddressPrefix = "10.0.0.0/24"
$PublicIPName = $vmname + "-pip"

New-AzureRmResourceGroup -Name $rgroup -Location $location

$storageAcc = New-AzureRmStorageAccount -Name $storage -ResourceGroupName $rgroup -SkuName Standard_LRS -Location $location -Kind Storage

$storageAcc = Get-AzureRmStorageAccount -Name $storage -ResourceGroupName $rgroup

$subnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetname -AddressPrefix $vnetSubnetAddressPrefix

$vnet = New-AzureRmVirtualNetwork -Name $vnetname -ResourceGroupName $rgroup -Location $location -AddressPrefix $vnetAddressPrefix -Subnet $subnet

$pip = New-AzureRmPublicIpAddress -Name $PublicIPName -ResourceGroupName $rgroup -Location $location -AllocationMethod Dynamic

$nic = New-AzureRmNetworkInterface -Name $nic -ResourceGroupName $rgroup -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id


#Credentials or your VM
$cred = Get-Credential -Message "Type the name and password for the local administrator account."

  
#Run this to create a Vm from Windows image 
#$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version latest
#Find all the available publishers
$pubName = Get-AzurermVMImagePublisher -Location $location | Out-GridView -Title "Select Publisher" -PassThru 

#Pick a specific offer
$offerName = Get-AzurermVMImageOffer -Location $location -Publisher $pubName.PublisherName | Out-GridView -Title "Select Offer" -PassThru 

 
#View the different SKUs
$skuname = Get-AzurermVMImageSku -Location $location -Publisher $pubName.PublisherName -Offer $offerName.Offer | Out-GridView -Title "Select Sku" -PassThru

#View the versions of a SKU
$image = Get-AzurermVMImage -Location $location -PublisherName $pubName.PublisherName -Offer $offerName.Offer -Skus $skuname.Skus | Out-GridView -Title "Select Version" -PassThru

#View detail of a specific version of the SKU

#Assign Virtual machine and image config
$vmconfig = New-AzureRmVMConfig -VMName $vmname -VMSize $vmSize

$vm = Set-AzureRmVMOperatingSystem -VM $vmconfig  -ComputerName $computerName -Credential $cred -Linux

$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName $image.PublisherName -Offer $image.Offer -Skus $image.Skus -Version $image.Version
 
#Add the NIC to the VM and set one of the NIC as primary

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

$vm.NetworkProfile.NetworkInterfaces.Item(0).Primary = $true

$osDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $osDiskName + ".vhd"

$osDiskUri
$osDiskName = $osDiskName + ".vhd"

$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -Linux -VhdUri $osDiskUri -CreateOption FromImage -DiskSizeInGB 127 -Caching ReadWrite

# 6. create the VM
New-AzureRmVM -ResourceGroupName $rgroup -Location $location -VM $vm


