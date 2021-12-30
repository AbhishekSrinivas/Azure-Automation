workflow Parallel-New-Gulab
{

Param 
    (
        [Parameter(Mandatory=$true)]
        [String] $NewVMName,

        [Parameter(Mandatory=$true)]
        [String] $VMLocation,

        [Parameter(Mandatory=$true)]
        [String] $VMSize,

        [Parameter(Mandatory=$true)]
        [String] $OSProfile,

        [Parameter(Mandatory=$true)]
        [String] $SourceImageRGName,

        [Parameter(Mandatory=$true)]
        [String] $SourceImageName,

        [Parameter(Mandatory=$true)]
        [String] $SharedResourcesRGName,

        [Parameter(Mandatory=$true)]
        [String] $NSGName,

        [Parameter(Mandatory=$true)]
        [String] $VNetName,

        [Parameter(Mandatory=$true)]
        [String] $SubnetName,

        [Parameter(Mandatory=$true)]
        [String] $AddPrefix,

        [Parameter(Mandatory=$true)]
        [String] $AdminUserName,

        [Parameter(Mandatory=$true)]
        [String] $AdminPassword,

        [Parameter(Mandatory=$true)]
        [String] $NoofVMs,

        [Parameter(Mandatory=$true)]
        [String] $DataDSKSize
    )


"#******************************* Login to Azure Run As Connection ********************************************#"
$connectionName = "AzureRunAsConnection"
    
Try
    {
# Get the connection "AzureRunAsConnection"
        
            $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

"Logging in to Azure..."

            Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }

Catch 
    {
        if (!$servicePrincipalConnection)
            {
                $ErrorMessage = "Connection $connectionName not found."
                throw $ErrorMessage
            } 
        else
            {
                Write-Error -Message $_.Exception
                throw $_.Exception
                $ErrorMessage = $_.Exception

            }
    }   
"#******************************* Successfully Logged in to Azure Run As Connection ********************************#"
Try
    {
        InLineScript 
            {
                
$ErrorActionPreference = 'Stop'       

"Create ResourceGroup for Network Resources"

        New-AzureRmResourceGroup -Name $Using:SharedResourcesRGName -Location $Using:VMLocation -Force

"Successfully Created ResourceGroup for Network Resources" 

"Creating Shared Network Resources for all NewVMs"

"Creating New Network Security Group"

        $nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $Using:SharedResourcesRGName -Location $Using:VMLocation `
        -Name $Using:NSGName

"Creating Virtual Network and Subnet Config"

        $subnet = New-AzureRmVirtualNetworkSubnetConfig -Name $Using:SubnetName -AddressPrefix $Using:AddPrefix

        $vnet = New-AzureRmVirtualNetwork -Name $Using:VNetName -ResourceGroupName $Using:SharedResourcesRGName `
        -Location $Using:VMLocation -AddressPrefix $Using:AddPrefix -Subnet $subnet

"Associating Virtual Network with Subnet"

        Set-AzureRmVirtualNetworkSubnetConfig -Name $subnet.Name -VirtualNetwork $vnet -AddressPrefix $Using:AddPrefix
            
        Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
            
            } #InLineScript Closes here.
            
Foreach -parallel ($i in 1..$NoofVMs)
    
    {
        InlineScript 
                    {

$ErrorActionPreference = 'Stop'
$i = $Using:i 
$VMName = $Using:NewVMName + $i.ToString("000")
$DNSName = $VMName.ToLower()

"Creating New ResourceGroup - $VMName"

        New-AzureRmResourceGroup -Name $VMName -Location $Using:VMLocation -Force

"Successfully Created ResourceGroup - $VMName" 

"Creating Network Config for $VMName"

#"Get Network Security Group & Virtual Network Information"

$gnsg = Get-AzureRmNetworkSecurityGroup -Name $Using:NSGName -ResourceGroupName $Using:SharedResourcesRGName
$gvnet = Get-AzureRmVirtualNetwork -Name $Using:VNetName -ResourceGroupName $Using:SharedResourcesRGName

"Creating Public IP with DNS Name for $VMName"

        $pip = New-AzureRmPublicIpAddress -Name "$VMName-PIP" -ResourceGroupName $VMName -Location $Using:VMLocation `
        -AllocationMethod Dynamic -DomainNameLabel $DNSName -Force

"Creating Network Interface Card for $VMName"

        $nic = New-AzureRmNetworkInterface -Name "$VMName-NIC" -ResourceGroupName $VMName -Location $Using:VMLocation `
        -SubnetId $gvnet.Subnets[0].ID -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $gnsg.Id -Force

        $image = Get-AzureRMImage -ImageName $Using:SourceImageName -ResourceGroupName $Using:SourceImageRGName
     
"Successfully Created Network Config for $VMName"     

"Add and Set New VMSize, OS Profile and Credentials to $VMName"

        $cred = New-Object PSCredential $Using:AdminUserName, ($Using:AdminPassword | ConvertTo-SecureString -AsPlainText -Force)

        $ComputerName = $VMName
        
        $vm = New-AzureRmVMConfig -VMName $VMName -VMSize $Using:VMSize

        $vm = Set-AzureRmVMSourceImage -VM $vm -Id $image.Id

If ($Using:OSProfile -eq 'Linux')
    {
"Configuring $VMName for Linux Environment"
       
        $vm = Set-AzureRmVMOSDisk -VM $vm -StorageAccountType StandardLRS -CreateOption FromImage -Linux `
        -Caching ReadWrite -Name $VMName

        $vm = Set-AzureRmVMOperatingSystem -VM $vm -Linux -ComputerName $ComputerName -Credential $cred

"Successfully Configured $VMName for Linux Environment"
    }

ElseIf ($Using:OSProfile -eq 'Windows')
    {
"Configuring $VMName for Windows Environment"
       
        $vm = Set-AzureRmVMOSDisk -VM $vm -StorageAccountType StandardLRS -CreateOption FromImage -Windows `
        -Caching ReadWrite -Name $VMName

        $vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $ComputerName -Credential $cred

"Successfully Configured $VMName for Windows Environment"
    }

"Associating Network Interface Card for $VMName"

        $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
        
"Network Interface Card Successfully Associated with $VMName"

        $vm = Set-AzureRmVMBootDiagnostics -VM $vm -Disable

"Adding the Config to an VM Array and Creating VM - $VMName - Please Wait ...................."

        New-AzureRmVM -VM $vm -ResourceGroupName $VMName -Location $Using:VMLocation

"Successfully Deployed NewVM - $VMName"

If ($Using:DataDSKSize -eq "0")

    {"Not Selected any Datadisk to Add to NewVM - $VMName"}
Else
    {
"Adding Data Disk to NewVM - $VMName"

        $diskConfig = New-AzureRmDiskConfig -AccountType StandardLRS -Location $Using:VMLocation -CreateOption Empty `
        -DiskSizeGB $Using:DataDSKSize

        $dataDisk1 = New-AzureRmDisk -DiskName "$VMName-DataDisk" -Disk $diskConfig -ResourceGroupName $VMName

        $vm = Get-AzureRmVM -Name $VMName -ResourceGroupName $VMName 

        $vm = Add-AzureRmVMDataDisk $vm -Name "$VMName-DataDisk" -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 0
        Update-AzureRmVM -VM $vm -ResourceGroupName $VMName

"Successfully Added Data Disk to NewVM - $VMName"
    }
                    }#InlineScript Closes here.
     
    } #Foreach Parallel Closes here.
    } #Try Block Closes here. 

Catch 
        {
            write-output "Exception Caught..." 
            Write-Error -Message $_.Exception 
            $ErrorMessage = $_.Exception.Message   
            Write-Output "Error Occurred: Message: $ErrorMessage." 

Foreach -parallel ($i in 1..$NoofVMs)
    
    {
$VMName = "$NewVMName"+$i.ToString("00")
            
            Remove-AzureRmResourceGroup $VMName -Force

            Remove-AzureRmResourceGroup $Using:SharedResourcesRGName -Force
    }

        } #Catch Block Closes here.

} #WorkFlow Closes here.
