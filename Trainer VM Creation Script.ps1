#VHD Image deploy script

#Deploy New VM with new storage account using custom vhd in a different storage account



# Sign-in with Azure account credentials

Select-AzureRmProfile -Path C:\users\gulab\Desktop\Reshma-Azure.json


## Global Variables
$ResourceGroupName = "BigData-TRNRVM"
$location = "South India"

# Storage
$storageName = "bgdtrnrstg"
$storageType = "Standard_DS1_V2"


## Network
$nicname = "BGDTRNR-NIC"
$subnetName = "BGDTRNR-Subnet"
$vnetName = "BGDTRNR-VNet"
$vnetAddressPrefix = "10.0.0.0/26"
$vnetSubnetAddressPrefix = "10.0.0.0/26"
$publicIPName = "BGDTRNR-PIP"
$nsgname='BGDTRNR-NSG'
$allocationmethod='static' #dynamic
$DomainNameLabel='bigdatatrnr'

## Compute
$vmName = "BigData-TRNRVM"
$computerName = "BigData-TRNRVM"
$vmSize = "Standard_DS1_V2"
$osDiskName = $vmName + "osDisk"
$blobPath = "vhds/srcosDisk.vhd"

########################################

#SOURCE STORAGE ACCOUNT VARIABLES

$SourceRGName='VHD-Image'
$srcUri = "https://bigdatastgraw.blob.core.windows.net/bigdatastgraw/Bigdata-TRNGSetup21-12-2016.vhd"
$srcStorageAccount = "bigdatastgraw"

########################################

#DESTINATION STORAGE ACCOUNT VARIABLES(information of newly created storage account)
$destRGName = $ResourceGroupName
#Destination storage account name
$destStorageAccount = $storageName
#Destination container name
$containerName = "bgdtrnrcnt" 
#Destinationblobname 
$DestBlob = "bgdtrnrdep.vhd"

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


################################################################################################################
#CREATE NSG WITH RULES TO ENABLE RDP 
#Create a security rule allowing access from the Internet to port 3389


$rule1 = New-AzureRmNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

#Create a security rule allowing access from the Internet to port 22 for SSH.

$rule2 = New-AzureRmNetworkSecurityRuleConfig -Name SSH-rule -Description "Allow SSH" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 22

#Add the rules created above to a new NSG named NSG-FrontEnd

#New-AzureRmResourceGroup -Name TestRG -Location westus

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $location -Name $nsgname `
    -SecurityRules $rule1,$rule2


#Check the rules created in the NSG.

$nsg

############################################################################################################
              
#Create a virtual network
$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $vnetSubnetAddressPrefix
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $ResourceGroupName -Location $location -AddressPrefix $vnetAddressPrefix -Subnet $singleSubnet 
#Associate the NSG created above to the FrontEnd subnet

$vnet= Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -name $vnetName
Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName -AddressPrefix $vnetAddressPrefix -NetworkSecurityGroup $nsg

#Save the new VNet settings to Azure.

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet

#Create a public IP address and network interface
$pip = New-AzureRmPublicIpAddress -Name $publicIPName -ResourceGroupName $ResourceGroupName -Location $location -AllocationMethod $allocationmethod -DomainNameLabel $DomainNameLabel
$nic = New-AzureRmNetworkInterface -Name $nicname -ResourceGroupName $ResourceGroupName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id 

########################################################################################################################################################################
#
#Create a virtual machine

#The password must be at 12-123 characters long and have at least one lower case character, one upper case character, one number, and one special character. 
#$cred = Get-Credential -Message "Type the name and password of the local administrator account."

#The password must be at 12-123 characters long and have at least one lower case character, one upper case character, one number, and one special character. 
$adminUsername = 'g7admin'
$adminPassword = 'P@ssw0rd@123'	
$cred = New-Object PSCredential $adminUsername, ($adminPassword | ConvertTo-SecureString -AsPlainText -Force)  


$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

$vm = Set-AzureRmVMOperatingSystem -VM $vm  -Linux -ComputerName $computerName -Credential $cred 

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id


#Create New Os Disk uri
$osdiskuriname='bdgtrnrOSD.vhd'
$osDiskUri = "https://$destStorageAccount.blob.core.windows.net/$containerName/$osdiskuriname"
#https://demo1storageacc.blob.core.windows.net/demostoragecontainer/MYNEWVM.vhd

#Image URI you can Find Storage group --> Blob --> System -->Microsoft.Compute -->Images --> your conntainer Name --> vhd name given while caputure VM.
$imageUri = "https://$destStorageAccount.blob.core.windows.net/$containerName/$DestBlob"
$vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption FromImage -SourceImageUri $imageUri  -Caching ReadWrite -Linux

#running below command you can see your VM attached parameters.
$vm

#Create the new VM
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $location -VM $vm
