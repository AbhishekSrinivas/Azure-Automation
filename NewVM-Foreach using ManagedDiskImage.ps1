Select-AzureRmProfile C:\users\adm_gulab\Desktop\m4l.json

Select-AzureRmSubscription -SubscriptionName "G7CRM4L08"

#Global Varialbes **************************

$SharedResourcesRGName = "NewRG-4-Resources"
$NSGName = "New-NSG"
$VNetName = "New-VNet"
$SubnetName = "New-Subnet"
$AddPrefix = "10.0.0.0/26"

$NewVMName = "GulabDemoVM"
$VMLocation = 'SouthIndia'
$VMSize = "Standard_DS2_V2"
$SourceImageRGName = "M4lTemplates"
$SourceImageName = "m4l01s2_img"
$OSProfile = "Linux"
$AdminUserName = "gulabadmin"
$AdminPassword = 'ap@m4l$1CR'
$DataDskSize = "50"

#*******************************************

"Creating New Shared Resouces Resource Group"

    New-AzureRmResourceGroup -Name $SharedResourcesRGName -Location $VMLocation -Force
    
"Creating Shared Network Resources for all New VM's"

"Creating Network Security Group with Rules to ENABLE RDP & SSH"

$rule1 = New-AzureRmNetworkSecurityRuleConfig -Name rdp-rule -Description "Allow RDP" -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
        -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

$rule2 = New-AzureRmNetworkSecurityRuleConfig -Name web-rule -Description "SSH Port" -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 `
        -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 22

$nsg = New-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $SharedResourcesRGName -Location $VMLocation -SecurityRules $rule1,$rule2 -Force

$subnet = New-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $ADDPrefix 

$vnet = New-AzureRmVirtualNetwork -Name "$VNetName" -ResourceGroupName $SharedResourcesRGName -Location $VMLocation -AddressPrefix $AddPrefix -Subnet $subnet -Force

Set-AzureRmVirtualNetworkSubnetConfig -Name $subnet.Name -VirtualNetwork $vnet -AddressPrefix $AddPrefix
    
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet


foreach ($i in 1..2)

{

    $VMName = "$NewVMName"+$i.ToString("00")


#DNSName is case senstitive, so recommend to use always lower case.

$DNSName = $VMName.ToLower() 
            
"Create ResourceGroup for VMName"

        New-AzureRmResourceGroup -Name $VMName -Location $VMLocation -Force

"Successfully Created ResourceGroup" 

"#Creating Network Config Foreach VM"

        $vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $SharedResourcesRGName

        $nsg = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $SharedResourcesRGName

        $pip = New-AzureRmPublicIpAddress -Name "$VMName-PIP" -ResourceGroupName $VMName -Location $VMLocation -AllocationMethod Dynamic `
        -DomainNameLabel $DNSName -Force

        $nic = New-AzureRmNetworkInterface -Name "$VMName-NIC" -ResourceGroupName $VMName -Location $VMLocation -SubnetId $vnet.Subnets[0].id `
        -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id -Force


        $image = Get-AzureRMImage -ImageName $SourceImageName -ResourceGroupName $SourceImageRGName
        
        
"#Successfully Created Network Config Foreach VM"     

"Adding and Configuring VMSize, OS Profile and Credentials for $VMName"

        $cred = New-Object PSCredential $AdminUserName, ($AdminPassword | ConvertTo-SecureString -AsPlainText -Force)

        $ComputerName = $VMName
        
        $vm = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize

        $vm = Set-AzureRmVMSourceImage -VM $vm -Id $image.Id

If ($OSProfile -eq 'Linux')
    {
"Configuring $VMName for Linux Environment"
       
        $vm = Set-AzureRmVMOSDisk -VM $vm -StorageAccountType StandardLRS -CreateOption FromImage -Linux -Caching ReadWrite -Name $VMName

        $vm = Set-AzureRmVMOperatingSystem -VM $vm -Linux -ComputerName $ComputerName -Credential $cred 

"Successfully Configured $VMName for Linux Environment"
    }

ElseIf ($OSProfile -eq 'Windows')
    {
"Configuring $VMName for Windows Environment"
       
        $vm = Set-AzureRmVMOSDisk -VM $vm -StorageAccountType StandardLRS -CreateOption FromImage -Windows -Caching ReadWrite -Name $VMName

        $vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $ComputerName -Credential $cred 

"Successfully Configured $VMName for Windows Environment"
    }

"Associating Network Interface Card with VMName"

        $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
        
"Network Interface Card Successfully Associated with VMName"

        $vm = Set-AzureRmVMBootDiagnostics -VM $vm -Disable

"Adding the Config to an VM Array and Creating VMName - Please Wait ...................."

        New-AzureRmVM -VM $vm -ResourceGroupName $VMName -Location $VMLocation

"Successfully Deployed New VM - $VMName"


If ($DataDSKSize -ne $null)
    {
"Adding Data Disk to NewVM"

        $diskConfig = New-AzureRmDiskConfig -AccountType StandardLRS -Location $VMLocation -CreateOption Empty `
        -DiskSizeGB $DataDSKSize

        $dataDisk1 = New-AzureRmDisk -DiskName "$VMName-DataDisk" -Disk $diskConfig -ResourceGroupName $VMName

        $vm = Get-AzureRmVM -Name $VMName -ResourceGroupName $VMName 

        $vm = Add-AzureRmVMDataDisk $vm -Name "$VMName-DataDisk" -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 0
        Update-AzureRmVM -VM $vm -ResourceGroupName $VMName

"Successfully Added Data Disk to NewVM"
    }
Else {"Not Selected any Datadisk to Add to NewVM"}
   
    } #Foreach Parallel Closes here.
