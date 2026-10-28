#Deploy New VM with new storage account using custom vhd in a different storage account


# Sign-in with Azure account credentials
Login-AzureRmAccount


# Select your Azure Subscription.

$subscriptionId = 
    (Get-AzureRmSubscription |
     Out-GridView `
        -Title "Select an Azure Subscription ..." `
        -PassThru).SubscriptionId

Select-AzureRmSubscription `
    -SubscriptionId $subscriptionId


## Global Variables
$ResourceGroupName = "Attendee01RG"
$location = "Southindia"

# Storage
$storageName = "attendee001stg"

## Network
$nicname = "attendee01nic"
#$subnetName ="attendee01subnet"
#$vnetName = "attendee01vnet"
#$vnetAddressPrefix = "10.0.0.0/24"
$vnetSubnetAddressPrefix = "10.1.0.0/27"
$publicIPName = "attendee01pip"

$allocationmethod='static' #dynamic
$DomainNameLabel='attendee01rg'

## Compute
$vmName = "attendee01vm"
$computerName = "attendee01comp"
$vmSize = "Standard_DS2_V2"
$osDiskName = $vmName + "osDisk"
$osdiskuriname='attendee01osdisk.vhd'
$blobPath = "vhds/srcosDisk.vhd"

#credentials
$adminUsername = 'ContosoAdmin'
$adminPassword = '<PASSWORD>'	

########################################

#SOURCE STORAGE ACCOUNT VARIABLES
$SourceRGName='Images'
$srcUri = "https://<storage-account>.blob.core.windows.net/win10/Win10_zenoxx.vhd"
$srcStorageAccount = "zenoxx"

########################################

#DESTINATION STORAGE ACCOUNT VARIABLES(information of newly created storage account)
$destRGName = $ResourceGroupName
#Destination storage account name
$destStorageAccount = $storageName
#Destination container name
$containerName = "attendee01cnt" 
#Destinationblobname 
$DestBlob = "attendee01.vhd"

###########################################################################################

#Create New Resouce Group

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $location

#Create New Storage

$storageAcc = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $storageName -SkuName "Standard_LRS" -Kind "Storage" -Location $location

### Source Storage Account Key ###

$srcStorageKey = (Get-AzureRmStorageAccountkey -ResourceGroupName $SourceRGName -Name $srcStorageAccount).Value[0]



### Target Storage Account key###
$destStorageKey = (Get-AzureRmStorageAccountkey -ResourceGroupName $destRGName -Name $destStorageAccount).Value[0]
  
### Create the source storage account context ### 
$srcContext = New-AzureStorageContext   -StorageAccountName $srcStorageAccount `
                                        -StorageAccountKey $srcStorageKey 
  
### Create the destination storage account context ### 
$destContext = New-AzureStorageContext  -StorageAccountName $destStorageAccount `
                                        -StorageAccountKey $destStorageKey 

  
### Create the container on the destination ### 
New-AzureStorageContainer -Name $containerName -Context $destContext
  
### Start the asynchronous copy - specify the source authentication with -SrcContext ### 
$blob1 = Start-AzureStorageBlobCopy -srcUri $srcUri `
                                    -SrcContext $srcContext `
                                    -DestContainer $containerName `
                                    -DestBlob $DestBlob `
                                    -DestContext $destContext
 
### Retrieve the current status of the blob copy operation ###
$status = $blob1 | Get-AzureStorageBlobCopyState
  
### Print out status ### 
$status
  
### Loop until complete ###                                    
While($status.Status -eq "Pending"){
  $status = $blob1 | Get-AzureStorageBlobCopyState
  Start-Sleep 10
  ### Print out status ###
  $status
}

############################################################################################################
$nsg =Get-AzureRmNetworkSecurityGroup -ResourceGroupName 'TrainerwsRG' -Name 'TrainerwsNSG' 

#Create a virtual network
$vnet = get-AzureRmVirtualNetwork -Name 'trainerwsvnet' -ResourceGroupName 'TrainerwsRG' 

$vnet= Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet  -Name 'trainerwssubnet' -AddressPrefix $vnetSubnetAddressPrefix  -NetworkSecurityGroup $NSG

#Save the new VNet settings to Azure.srcsubnet


Set-AzureRmVirtualNetwork -VirtualNetwork $vnet   

#Create a public IP address and network interface
$pip = New-AzureRmPublicIpAddress -Name $publicIPName -ResourceGroupName $ResourceGroupName -Location $location -AllocationMethod $allocationmethod -DomainNameLabel $DomainNameLabel 
$nic = New-AzureRmNetworkInterface -Name $nicname -ResourceGroupName $ResourceGroupName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id 
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $nicname 
$nic.NetworkSecurityGroup = $nsg
Set-AzureRmNetworkInterface -NetworkInterface $nic
########################################################################################################################################################################

#Create a virtual machine

#The password must be at 12-123 characters long and have at least one lower case character, one upper case character, one number, and one special character. 

$cred = New-Object PSCredential $adminUsername, ($adminPassword | ConvertTo-SecureString -AsPlainText -Force)  

$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $computerName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id


#Create New Os Disk uri

$osDiskUri = "https://$destStorageAccount.blob.core.windows.net/$containerName/$osdiskuriname"

#Image URI you can Find Storage group --> Blob --> System -->Microsoft.Compute -->Images --> your conntainer Name --> vhd name given while caputure VM.
$imageUri = "https://$destStorageAccount.blob.core.windows.net/$containerName/$DestBlob"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption FromImage -SourceImageUri $imageUri  -Caching ReadWrite -Windows

#running below command you can see your VM attached parameters.
$vm

#Create the new VM
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $location -VM $vm


$userName = "contosoadmin"
$pwd = "<PASSWORD>"
$SettingsString = '{"UserName":"' + $userName + '"}';
$ProtectedSettingsString = '{"Password":"' + $pwd + '"}';
Set-AzureRmVMExtension -Location $location -ResourceGroup $ResourceGroupName -VM $vmName -ExtensionType "VMAccessAgent" -ExtensionName "VMAccess" -Publisher "Microsoft.Compute" -Version "2.0" -SettingString $SettingsString -ProtectedSettingString $ProtectedSettingsString