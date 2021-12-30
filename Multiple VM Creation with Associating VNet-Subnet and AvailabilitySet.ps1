
#********* The following Script helps to create Multiple VM's using customized VHD one after one but in Single Resource Group **********

####################################################################################################################################################

# Authenticate to the Azure Portal

Login-AzureRMAccount


$subscriptionId = 
    (Get-AzureRmSubscription |
     Out-GridView `
        -Title "Select an Azure Subscription ..." `
        -PassThru).SubscriptionId

Select-AzureRmSubscription `
    -SubscriptionId $subscriptionId
    

####################################################################################################################################################

#Destination Global Variables

# Where do we want to put the VM's

$global:locName = 'South India'

# Resource Group name

$global:rgName = 'BigData-ServerVM07'

# VM Size

$global:vmsize = 'Standard_DS1_v2'


####################################################################################################################################################


# Source VHD from which would like to deploy Multiple VMs.

$sourceURi = 'https://ubuntu14004raw.blob.core.windows.net/generalizedvhd/Bigdata-TRNGSetup21-12-2016.vhd'
$sourceRG = 'VHD'
$sourceSA = 'ubuntu14004raw'


####################################################################################################################################################


# VMName

# $global:NewVM = $null


# Name How many VM's who you like to Auto Deploy

$VMRole=@()

$VMRole+=,('bgdsrvrvm19')
$VMRole+=,('bgdsrvrvm20')
$VMRole+=,('bgdsrvrvm21')


####################################################################################################################################################

# Create Resource Group

New-AzureRmResourceGroup -Name $rgName -Location $locName

# Create Single Availability set and associate all VMS with it

$AVSet = New-AzureRmAvailabilitySet -ResourceGroupName $rgName -Location $locName -Name 'Server-AvSet' -PlatformUpdateDomainCount 5 -PlatformFaultDomainCount 3


####################################################################################################################################################


# VM Config for each VM

# Create VMConfigs and add to an array

foreach ($NewVM in $VMRole){

    # ******** Create IP and Network for the VM ***************************************

    # *****We do this upfront before the bulk create of the VM**************

    $pip = New-AzureRmPublicIpAddress -Name "$NewVM-PIP" -ResourceGroupName $rgName -Location $locName -AllocationMethod Static -DomainNameLabel $NewVM

    $nic = New-AzureRmNetworkInterface -Name "$NewVM-NIC" -ResourceGroupName $rgName -Location $locName -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id


#Network Configuration Details
# You can create Virtual Network, Subnet and Network Security Group for each of the VM or you can attach the existing Network Config 


#$global:nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName 'BigData-TRNRVM' -Name 'BGDTRNR-NSG'

$global:vnet = get-AzureRmVirtualNetwork -Name 'NRPVNet' -ResourceGroupName 'LoadBalancer-Demo02'

$singleSubnet = Set-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name 'LB1-Subnet' -AddressPrefix 10.0.2.0/24 

####################################################################################################################################################


    # Create RG Storage Account & Blob Container

    $storageAcc = New-AzureRmStorageAccount -ResourceGroupName $rgName -Name $NewVM  -Type "Standard_LRS" -Location $locName

    # Create the container on the destination ### 

      $stgcnt = New-AzureStorageContainer -Name $NewVM -Permission Off -Context $storageAcc.Context

####################################################################################################################################################

### Target Storage Account key###
$destStorageKey = (Get-AzureRmStorageAccountkey -ResourceGroupName $rgName -Name $storageAcc.StorageAccountName).Value[0]
# This should be $storageAcc.StorageAccountName. The same to following situations.


### Create the destination storage account context ### 
$destContext = New-AzureStorageContext  -StorageAccountName $storageAcc.StorageAccountName -StorageAccountKey $destStorageKey

### Source Storage Account key###
$srcStorageKey = (Get-AzureRmStorageAccountkey -ResourceGroupName $sourceRG -Name $sourceSA).Value[0]

### Create the source storage account context ###
$srcContext = New-AzureStorageContext -StorageAccountName $sourceSA -StorageAccountKey $srcStorageKey 

#The context of the source storage accout, are also required while copying the VHD(blob storage).

### Start the asynchronous copy - specify the source authentication with -SrcContext ### 
$blobcopy = Start-AzureStorageBlobCopy -srcUri "$sourceURi" -DestContainer $stgcnt.Name -DestBlob "$NewVM.vhd" -Context $srcContext -DestContext $destContext -Force

### The asynchronous copy need to be set as one variable, then $status can be set as $status = $blobcopy | Get-AzureStorageBlobCopyState
                                   
 
### Retrieve the current status of the blob copy operation ###

$status = $blobcopy | Get-AzureStorageBlobCopyState

#The copy operation should be very quick. So the below Loop part may be able to be removed.

### Print out status ### 
$status
  
### Loop until complete ###                                    
While($status.Status -eq "Pending"){
  $status = $blobcopy | Get-AzureStorageBlobCopyState
  Start-Sleep 10
  ### Print out status ###
  $status
}

####################################################################################################################################################



# Get the UserID and Password info that we want associated with the new VM's.


#The password must be at 12-123 characters long and have at least one lower case character, one upper case character, one number, and one special character. 
$adminUsername = 'g7admin'
$adminPassword = 'P@ssw0rd@123'	
$cred = New-Object PSCredential $adminUsername, ($adminPassword | ConvertTo-SecureString -AsPlainText -Force)


#Add and Set New VMSize and set OS and credentials and set AvailabilitySet to your VM

    $vm = Get-AzureRmAvailabilitySet -ResourceGroupName $rgName -Name 'Server-AvSet'

    $vm = New-AzureRmVMConfig -VMName $NewVM -VMSize "$vmsize" -AvailabilitySetId $AVSet.Id

    $vm = Set-AzureRmVMOperatingSystem -VM $vm -Linux -ComputerName $NewVM -Credential $cred
    
    $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

        
    # VM Disks. Deploying an OS for each

    $imageUri = "https://" + $storageAcc.StorageAccountName + ".blob.core.windows.net/" + $stgcnt.Name + "/$NewVM.vhd" 


####################################################################################################################################################
    
    #Following will help to add Data Disk to each of th VM - "Uncommnet if you want to add Data Disk for each VM"
        
    #$DataDiskUri = $storageAcc.PrimaryEndpoints.Blob.ToString() + "vhds/DataDisk$NewVM.vhd"
    
    #$DataDiskName= $NewVM + "dsk"

    #$vm = Add-AzureRmVMDataDisk -VM $vm -Name $DataDiskName -VhdUri $DataDiskUri -LUN 0 -Caching ReadWrite -DiskSizeinGB "128" -CreateOption Empty -Verbose

####################################################################################################################################################

    $osDiskName = $NewVM + "osDisk"

    $osDiskUri = "https://" + $storageAcc.StorageAccountName + ".blob.core.windows.net/" + $stgcnt.Name + "/$osDiskName.vhd"

    # $storageAcc and $stgcnt are 2 variables of config, not only the name. So I use $storageAcc.StorageAccountName and $stgcnt.Name

    $vm = Set-AzureRmVMOSDisk -VM $vm -Name "$NewVM" -VhdUri $osDiskUri -CreateOption FromImage -Linux -Caching ReadWrite -SourceImageUri $imageUri

  
    # Add the Config to an Array

    $vm

    New-AzureRmVM -ResourceGroupName $rgName -Location $locName -VM $vm

# Once VM get successfully deployed you can delete the extra copied blob VHD

    Get-AzureStorageBlob -Blob "$NewVM.vhd" -Container $NewVM -Context $destContext | Remove-AzureStorageBlob -Blob "$NewVM.vhd" -Container $NewVM -Force -Verbose

    # ******** End NEW VM ***************************************
    
} 
