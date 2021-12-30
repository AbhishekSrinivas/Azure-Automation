workflow Parallel-Creating-VM-with-NewName4EachVM-Image-Webhook
{

Param
    (
       [object] $WebhookData
    )
    
    $WebhookBody = $WebhookData.RequestBody

    $multiNNVM = ConvertFrom-Json -InputObject $WebhookBody

    $NewVMName01 = $multiNNVM.NewVMName01
    $NewVMName02 = $multiNNVM.NewVMName02
    $NewVMName03 = $multiNNVM.NewVMName03
    $NewVMName04 = $multiNNVM.NewVMName04
    $NewVMName05 = $multiNNVM.NewVMName05
    $NewVMName06 = $multiNNVM.NewVMName06
    $NewVMName07 = $multiNNVM.NewVMName07
    $NewVMName08 = $multiNNVM.NewVMName08
    $NewVMName09 = $multiNNVM.NewVMName09
    $NewVMName10 = $multiNNVM.NewVMName10
    $VMLocation = $multiNNVM.VMLocation
    $VMSize = $multiNNVM.VMSize
    $OSProfile = $multiNNVM.OSProfile
    $SourceImageRGName = $multiNNVM.SourceImageRGName
    $SourceImageName = $multiNNVM.SourceImageName
    $VNet_AddPrefix = $multiNNVM.VNet_AddPrefix
    $Subnet_AddPrefix = $multiNNVM.Subnet_AddPrefix
    $AdminUserName = $multiNNVM.AdminUserName
    $AdminPassword = $multiNNVM.AdminPassword
    $DataDSKSize = $multiNNVM.DataDSKSize  
  
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

$VMRole=@()

$VMRole+=,($NewVMName01)
$VMRole+=,($NewVMName02)
$VMRole+=,($NewVMName03)
$VMRole+=,($NewVMName04)
$VMRole+=,($NewVMName05)
$VMRole+=,($NewVMName06)
$VMRole+=,($NewVMName07)
$VMRole+=,($NewVMName08)
$VMRole+=,($NewVMName09)
$VMRole+=,($NewVMName10)

Foreach -parallel ($NewVMName in $VMRole)
{
    InlineScript 
            {
                Try
                    {

$ErrorActionPreference = 'Stop'
$VMName = $Using:NewVMName
$DNSName = $VMName.ToLower()

"Creating New ResourceGroup - $VMName"

        New-AzureRmResourceGroup -Name $VMName -Location $Using:VMLocation -Force

"Successfully Created ResourceGroup - $VMName" 

"Creating Network Config for $VMName"

"Creating Shared Network Resources for all NewVMs"

"Creating New Shared Network Security Group with NSG Rules"

$InRule1 = New-AzureRmNetworkSecurityRuleConfig -Name "WinRDP" -Description "Allow Windows RDP" `
    -Access Allow -Protocol * -Direction Inbound -Priority 101 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

$InRule2 = New-AzureRmNetworkSecurityRuleConfig -Name "SSH" -Description "Allow SSH" `
    -Access Allow -Protocol * -Direction Inbound -Priority 102 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 22

        $nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $VMName -Location $Using:VMLocation `
       -Name "$VMName-NSG" -SecurityRules $InRule1,$InRule2

"Creating New Shared Virtual Network and Subnet Config"

        $subnet = New-AzureRmVirtualNetworkSubnetConfig -Name "$VMName-Subnet" -AddressPrefix $Using:Subnet_AddPrefix

        $vnet = New-AzureRmVirtualNetwork -Name "$VMName-VNet" -ResourceGroupName $VMName `
        -Location $Using:VMLocation -AddressPrefix $Using:VNet_AddPrefix -Subnet $subnet


"Creating Public IP with DNS Name for $VMName"

        $pip = New-AzureRmPublicIpAddress -Name "$VMName-PIP" -ResourceGroupName $VMName -Location $Using:VMLocation `
        -AllocationMethod Dynamic -DomainNameLabel $DNSName -Force

"Creating Network Interface Card for $VMName"

        $nic = New-AzureRmNetworkInterface -Name "$VMName-NIC" -ResourceGroupName $VMName -Location $Using:VMLocation `
        -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id -Force

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
        -Caching ReadWrite -Name "$VMName-OSDisk"

        $vm = Set-AzureRmVMOperatingSystem -VM $vm -Linux -ComputerName $ComputerName -Credential $cred

"Successfully Configured $VMName for Linux Environment"
    }

ElseIf ($Using:OSProfile -eq 'Windows')
    {
"Configuring $VMName for Windows Environment"
       
        $vm = Set-AzureRmVMOSDisk -VM $vm -StorageAccountType StandardLRS -CreateOption FromImage -Windows `
        -Caching ReadWrite -Name "$VMName-OSDisk"

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

} #Try Block Closes here. 

Catch 
        {
            write-output "Exception Caught..."
            $ErrorMessage = $_.Exception.Message
            Write-Output "Error Occurred: Message: $ErrorMessage" 
            Remove-AzureRmResourceGroup -Name $VMName -Force

"Sending EMail for Support Ticket to Create VM"

$SMTPServer = "smtp.office365.com"
$SMTPPort = "587"
$Username = "gulab.pasha@g7cr.in"
$Password = "xxxxxx" 
$to = "sonali.wetal@g7cr.in"
$cc = 'gulab.pasha@g7cr.in'

$subject = "Job Failed to Create NewVM - $VMName"

$body = "**************************************************************************************************** `n 
$ErrorMessage `n `n 

**************************************************************************************************** `n `n 

VMName = $VMName`n 
VMLocation = $Using:VMLocation `n 
VMZSize = $Using:VMSize `n 
OSProfile = $Using:OSProfile `n 
SourceImageRGName = $Using:SourceImageRGName `n 
SourceImageName = $Using:SourceImageName `n 
VNet_AddPrefix = $Using:VNet_AddPrefix `n 
Subnet_AddPrefix = $Using:Subnet_AddPrefix `n 
AdminUserName = $Using:AdminUserName `n 
AdminPassword = $Using:AdminPassword `n 
DataDSKSize = $Using:DataDSKSize `n

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

            } #Catch Block Closes here.          
        } #Catch Block InLineScript Closes here. 
    } #Foreach Parallel Closes here.
} #WorkFlow Closes here.

