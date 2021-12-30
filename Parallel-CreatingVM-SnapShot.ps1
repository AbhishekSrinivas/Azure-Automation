workflow Parallel-CreatingVM-SnapShot
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
        [String] $SharedResourcesRGName,

        [Parameter(Mandatory=$true)]
        [String] $SnapShotName,

        [Parameter(Mandatory=$true)]
        [String] $NSGName,

        [Parameter(Mandatory=$true)]
        [String] $VNetName,

        [Parameter(Mandatory=$true)]
        [String] $SubnetName,

        [Parameter(Mandatory=$true)]
        [String] $VNet_AddPrefix,

        [Parameter(Mandatory=$true)]
        [String] $Subnet_AddPrefix,

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
        InlineScript 
            {
                
$ErrorActionPreference = "Stop"    

"Creating Shared Network Resources for all NewVMs"

"Creating New Shared Network Security Group with NSG Rules"

$InRule1 = New-AzureRmNetworkSecurityRuleConfig -Name "SSH" -Description "Allow SSH" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 22

$InRule2 = New-AzureRmNetworkSecurityRuleConfig -Name "WinRDP" -Description "Allow Windows RDP" `
    -Access Allow -Protocol * -Direction Inbound -Priority 101 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

$InRule3 = New-AzureRmNetworkSecurityRuleConfig -Name "HTTP" -Description "Allow Ping HTTP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 102 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 80

$InRule4 = New-AzureRmNetworkSecurityRuleConfig -Name "HTTPS" -Description "Allow HTTPS" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 103 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 443

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $Using:SharedResourcesRGName -Location $Using:VMLocation `
       -Name $Using:NSGName -SecurityRules $InRule1,$InRule2,$InRule3,$InRule4

"Creating New Shared Virtual Network and Subnet Config"

        $subnet = New-AzureRmVirtualNetworkSubnetConfig -Name $Using:SubnetName -AddressPrefix $Using:Subnet_AddPrefix

        $vnet = New-AzureRmVirtualNetwork -Name $Using:VNetName -ResourceGroupName $Using:SharedResourcesRGName `
        -Location $Using:VMLocation -AddressPrefix $Using:VNet_AddPrefix -Subnet $subnet
           
            } #InlineScript Closes here.
            
Foreach -parallel ($i in 1..$NoofVMs)
    
    {
        InlineScript 
                    {

$ErrorActionPreference = "Stop"

$i = $Using:i 
$VMName = $Using:NewVMName + $i.ToString("000")
$DNSName = $VMName.ToLower()

"Creating New ResourceGroup - $VMName"

        New-AzureRmResourceGroup -Name $VMName -Location $Using:VMLocation -Force

"Successfully Created ResourceGroup - $VMName" 

"Creating Network Config for $VMName"

#"Get Network Security Group & Virtual Network Information"

$GetNSG = Get-AzureRmNetworkSecurityGroup -Name $Using:NSGName -ResourceGroupName $Using:SharedResourcesRGName
$GetVNet = Get-AzureRmVirtualNetwork -Name $Using:VNetName -ResourceGroupName $Using:SharedResourcesRGName
$GetSNet = Get-AzureRmVirtualNetworkSubnetConfig -Name $Using:SubnetName -VirtualNetwork $GetVNet

"Creating Public IP with DNS Name for $VMName"

        $pip = New-AzureRmPublicIpAddress -Name "$VMName-PIP" -ResourceGroupName $VMName -Location $Using:VMLocation `
        -AllocationMethod Dynamic -DomainNameLabel $DNSName -Force

"Creating Network Interface Card for $VMName"

        New-AzureRmNetworkInterface -Name "$VMName-NIC" -ResourceGroupName $VMName -Location $Using:VMLocation `
        -SubnetId $GetSNet.Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $GetNSG.Id -Force

Start-Sleep -Seconds "5"

        $nic = Get-AzureRmNetworkInterface -Name "$VMName-NIC" -ResourceGroupName $VMName

        $snapshot = Get-AzureRmSnapshot -ResourceGroupName $Using:SharedResourcesRGName -SnapshotName $Using:SnapShotName

"Successfully Created Network Config for $VMName"     

"Add and Set New VMSize, OS Profile and Credentials to $VMName"

        $diskConfig = New-AzureRmDiskConfig -AccountType $storageType -Location $Using:VMLocation `
                      -SourceResourceId $snapshot.Id -CreateOption Copy
 
        New-AzureRmDisk -Disk $diskConfig -ResourceGroupName $VMName -DiskName "$VMName-OSDISK"
        
        $disk = Get-AzureRmDisk -DiskName "$VMName-OSDISK" -ResourceGroupName $VMName

        $vm = New-AzureRmVMConfig -VMName $VMName -VMSize $Using:VMSize
        
If ($Using:OSProfile -eq 'Linux')
    {
"Configuring $VMName for Linux Environment"
       
        $vm = Set-AzureRmVMOSDisk -VM $vm -ManagedDiskId $disk.Id -CreateOption Attach -Linux
    
"Successfully Configured $VMName for Linux Environment"
    }

ElseIf ($Using:OSProfile -eq 'Windows')
    {
"Configuring $VMName for Windows Environment"
       
        $vm = Set-AzureRmVMOSDisk -VM $vm -ManagedDiskId $disk.Id -CreateOption Attach -Windows

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
            $ErrorMessage = $_.Exception.Message
            Write-Output "Error Occurred: Message: $ErrorMessage" 

InlineScript 
            {

"Sending EMail for Support Ticket to Create VM"

$SMTPServer = "smtp.office365.com"
$SMTPPort = "587"
$Username = "gulab.pasha@g7cr.in"
$Password = "1659@aclboya4g" 
$to = "sonali.wetal@g7cr.in"
$cc = 'gulab.pasha@g7cr.in'

$subject = "Job Failed to Create NewVM - $VMName"

$body = "**************************************************************************************************** `n 
$ErrorMessage `n `n 

**************************************************************************************************** `n `n 

VMName = $VMName`n 
VMLocation = $VMLocation `n 
VMZSize = $VMSize `n 
OSProfile = $OSProfile `n 
SourceImg_Network_RGName = $SharedResourcesRGName `n 
SnapShotName = $SnapShotName `n 
VNetName = $VNetName `n 
SubNetName = $SubNetName `n 
PublicIPName = $VMName-PIP `n 
NSGName = $VMName-NSG `n 
VNet_SNetAddPrefix = $AddPrefix `n
DataDSKSize = $DataDSKSize `n

****************************************************************************************************"

$message = New-Object System.Net.Mail.MailMessage
$message.subject = $subject
$message.body = $body
$message.to.add($to)
$message.cc.add($cc)

$message.from = $username

$smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
$smtp.send($message)
write-output "Mail Sent" 
"***** End of Program in Fatal Error" 
            } #Catch Block InLineScript Closes here.
        } #Catch Block Closes here.

} #WorkFlow Closes here.
