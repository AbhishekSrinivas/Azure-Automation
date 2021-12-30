Select-AzureRmProfile -Profile C:\Users\gulab\Desktop\m4l.json

Select-AzureRmSubscription -SubscriptionName "G7CRM4L08"

       
$NewVMName = "gulabpsvm" 
$VMLocation = "SouthIndia"
$VMSize = "Standard_Ds1_V2"
$OSProfile = "Linux"
$SourceImageRGName = "M4LTemplates"
$SourceImageName = "m4l01s2_img"
$SharedResourcesRGName = "abdgulab-shared"
$NSGName = "abdgul-nsg"
$VNetName = "abdgul-vnet"
$SubnetName = "abdgul-subnet"
$AdminUserName = "m4ladmin"
$AdminPassword = "P@ssw0rd@123"
$DataDSKSize = "50"
$SNetAddPrefix = "10.0.0.0/26"
$VNetAddPrefix = "10.0.0.0/26"

"Create ResourceGroup for Resources"

        New-AzureRmResourceGroup -Name $SharedResourcesRGName -Location $VMLocation -Force

"Successfully Created ResourceGroup for Resources" 

"# Shared Network Resources for all NewVMs"

    $Nnsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $SharedResourcesRGName -Location $VMLocation `
    -Name $NSGName

    $NSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SNetAddPrefix

    $Nvnet = New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $SharedResourcesRGName `
    -Location $VMLocation -AddressPrefix $VNetAddPrefix -Subnet $NSubnet

    Set-AzureRmVirtualNetworkSubnetConfig -Name $NSubnet.Name -VirtualNetwork $Nvnet -AddressPrefix $SNetAddPrefix
    
    Set-AzureRmVirtualNetwork -VirtualNetwork $Nvnet

Foreach ($i in 1..1)
    
    {

$VMName = "$NewVMName"+$i.ToString("00")
            
"Create ResourceGroup for VMName"

        New-AzureRmResourceGroup -Name $VMName -Location $VMLocation -Force

"Successfully Created ResourceGroup" 

"#Creating Network Config Foreach VM"


        $pip = New-AzureRmPublicIpAddress -Name "$VMName-PIP" -ResourceGroupName $VMName -Location $VMLocation `
        -AllocationMethod Dynamic -DomainNameLabel $VMName -Force

        $nsg = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName "$SharedResourcesRGName"
        $vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $SharedResourcesRGName
        $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet

Write-Output $vnet.Subnets[0].Id

        $nic = New-AzureRmNetworkInterface -Name "$VMName-NIC" -ResourceGroupName $VMName -Location $VMLocation `
        -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id -Force
               
        $image = Get-AzureRMImage -ImageName $SourceImageName -ResourceGroupName $SourceImageRGName
        
        
"#Successfully Created Network Config Foreach VM"     

"Add and Set New VMSize, OS Profile and Credentials for VMName"

        $cred = New-Object PSCredential $AdminUserName, ($AdminPassword | ConvertTo-SecureString -AsPlainText -Force)

        $ComputerName = $VMName
        
        $vm = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize

        $vm = Set-AzureRmVMSourceImage -VM $vm -Id $image.Id

If ($OSProfile -eq 'Linux')
    {
"Configuring NewVM for Linux Environment"
       
        $vm = Set-AzureRmVMOSDisk -VM $vm -StorageAccountType StandardLRS -CreateOption FromImage -Linux `
        -Caching ReadWrite -Name $VMName

        $vm = Set-AzureRmVMOperatingSystem -VM $vm -Linux -ComputerName $ComputerName -Credential $cred 
"Successfully Configured NewVM for Linux Environment"
    }

ElseIf ($OSProfile -eq 'Windows')
    {
"Configuring NewVM for Windows Environment"
       
        $vm = Set-AzureRmVMOSDisk -VM $vm -StorageAccountType StandardLRS -CreateOption FromImage -Windows `
        -Caching ReadWrite -Name $VMName

        $vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $ComputerName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
"Successfully Configured NewVM for Windows Environment"
    }

"Associating Network Interface Card with VMName"

        $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
        
"Network Interface Card Successfully Associated with VMName"

        $vm = Set-AzureRmVMBootDiagnostics -VM $vm -Disable

"Adding the Config to an VM Array and Creating VMName - Please Wait ...................."

        New-AzureRmVM -VM $vm -ResourceGroupName $VMName -Location $VMLocation

"Successfully Deployed VMName - $VMName"

If ($DataDSKSize -contains '50','100','127','200')
    {
"# Adding Data Disk to NewVM"

        $diskConfig = New-AzureRmDiskConfig -AccountType StandardLRS -Location $VMLocation -CreateOption Empty `
        -DiskSizeGB $DataDSKSize

        $dataDisk1 = New-AzureRmDisk -DiskName "$VMName-DataDisk" -Disk $diskConfig -ResourceGroupName $VMName

        $vm = Get-AzureRmVM -Name $VMName -ResourceGroupName $VMName 

        $vm = Add-AzureRmVMDataDisk $vm -Name "$VMName-DataDisk" -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 0
        Update-AzureRmVM -VM $vm -ResourceGroupName $VMName

"# Successfully Added Data Disk to NewVM"
    
    }
Else {"Not Selected any Datadisk to Add to NewVM"}

        }