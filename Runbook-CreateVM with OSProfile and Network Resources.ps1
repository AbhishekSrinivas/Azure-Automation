Param
    (
        [Parameter(Mandatory=$true)]
        [String] $NewVMRGName,

        [Parameter(Mandatory=$true)]
        [String] $VMLocation,
        
        [Parameter(Mandatory=$true)]
        [String] $VMSize,

        [Parameter(Mandatory=$true)]
        [String] $VMName,

        [Parameter(Mandatory=$true)]
        [String] $AdminUserName ,

        [Parameter(Mandatory=$true)]
        [String] $AdminPassword,

        [Parameter(Mandatory=$true)]
        [String] $OSProfile,

        [Parameter(Mandatory=$true)]
        [String] $SourceImageRGName,

        [Parameter(Mandatory=$true)]
        [String] $SourceImageName,

        [Parameter(Mandatory=$true)]
        [String] $NSGRGName,

        [Parameter(Mandatory=$true)]
        [String] $NSGName
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

$ErrorActionPreference = "Stop" 
$DNSName = $VMName.ToLower()

"Create ResourceGroup for $VMName"

        New-AzureRmResourceGroup -Name $NewVMRGName -Location $VMLocation -Force

"Successfully Created ResourceGroup" 

#Get Source VM Image Name

        $image = Get-AzureRMImage -ImageName $SourceImageName -ResourceGroupName $SourceImageRGName

#Get Network Security Group to Associate with Network Interface Care"

        $nsg = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $NSGRGName 

"Creating Network Resources for NewVM - $VMName"
        
        $subnet = New-AzureRmVirtualNetworkSubnetConfig -Name "$VMName-Subnet" -AddressPrefix "10.0.0.0/29"
        
        $vnet = New-AzureRmVirtualNetwork -Name "$VMName-VNet" -ResourceGroupName $NewVMRGName `
        -Location $VMLocation -AddressPrefix "10.0.0.0/29" -Subnet $subnet

        $pip = New-AzureRmPublicIpAddress -Name "$VMName-PIP" -ResourceGroupName $NewVMRGName `
        -Location $VMLocation -AllocationMethod Dynamic -DomainNameLabel $DNSName

        $nic = New-AzureRmNetworkInterface -Name "$VMName-NIC" -ResourceGroupName $NewVMRGName `
        -Location $VMLocation -SubnetId $vnet.Subnets[0].id -NetworkSecurityGroupId $nsg.Id -PublicIpAddressId $pip.Id


"Add and Set New VMSize, OS Profile and Credentials for NewVM"

        $cred = New-Object PSCredential $AdminUserName, ($AdminPassword | ConvertTo-SecureString -AsPlainText -Force)
                   
        $vm = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize

        $vm = Set-AzureRmVMSourceImage -VM $vm -Id $image.Id

If ($OSProfile -eq 'Linux')
    {
"Configuring $VMName for Linux Environment"
       
        $vm = Set-AzureRmVMOSDisk -VM $vm -StorageAccountType StandardLRS -CreateOption FromImage -Linux -Caching ReadWrite -Name "$VMName-OSDisk"

        $vm = Set-AzureRmVMOperatingSystem -VM $vm -Linux -ComputerName $VMName -Credential $cred 

"Successfully Configured $VMName for Linux Environment"
    }

ElseIf ($OSProfile -eq 'Windows')
    {
"Configuring $VMName for Windows Environment"
       
        $vm = Set-AzureRmVMOSDisk -VM $vm -StorageAccountType StandardLRS -CreateOption FromImage -Windows -Caching ReadWrite -Name "$VMName-OSDisk"

        $vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $VMName -Credential $cred -ProvisionVMAgent

"Successfully Configured $VMName for Windows Environment"
    }

"Associating Network Interface Card with NewVM"

        $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
        
"Network Interface Card Successfully Associated with NewVM"

        $vm = Set-AzureRmVMBootDiagnostics -VM $vm -Disable

"Adding the Config to an VM Array and Creating NewVM - Please Wait ...................."

        New-AzureRmVM -VM $vm -ResourceGroupName $NewVMRGName -Location $VMLocation

"Successfully Deployed NewVM - $VMName"

"Deallocate the VM and Exit the Job"

            Stop-AzureRmVM -Name $VMName -ResourceGroupName $NewVMRGName -Force

"Successfully Deallocated NewVM - $VMName - NewVM is Ready to USE"


<#
"Updating the NewVM Creation Success info to SQL SP"

$Conn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:cgm4lsqlsrv.centralindia.cloudapp.azure.com;Database=TrainingCAGM4LDBPROD;User ID=m4lSPExecuterAzureJobs;Password=M4L!PE*eCuTe!9812;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;TrustServerCertificate=True;")

        $Conn.Open() 
        $Cmd=new-object system.Data.SqlClient.SqlCommand("exec [Operations].[Proc_UpdateDBOnMachineCreation] '$VMName','1'", $Conn) 
        Invoke-AARUScriptBlock -ScriptBlock{ $cmd.ExecuteNonQuery(); } -Retries 3 -RetryInterval 20
        $Conn.Close();
#>

"VM Creation Job Completed Sucesfully"
      
            } #Try Block Closes Here

Catch
    {
        
            write-output "Exception Caught..."  
            $ErrorMessage = $_.Exception.Message   
            $StackTrace = $_.Exception.StackTrace   
            Write-Output "Error Occurred: Message: $ErrorMessage, stack: $StackTrace." 

            Remove-AzureRmResourceGroup -Name $NewVMRGName -Force

$Resourcegroup = "Auto4NewScripts"
$AutoAcc = "newautoacc"

$GetSCHTime = Get-AzureRmAutomationSchedule -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoACC | select Name,StartTime

$ScheduleCVMTime = $GetSCHTime | where { $_.name -eq $VMName+"CVM" } | select StartTime
$ScheduleDVMTime = $GetSCHTime | where { $_.name -eq $VMName+"DVM" } | select StartTime 


"Sending EMail for Support Ticket to Create VM"

$SMTPServer = "smtp.office365.com"
$SMTPPort = "587"
$Username = "gulab.pasha@g7cr.in"
$Password = "1659@aclboya4g" 
$to = "gulab.pasha@g7cr.in"
$cc = "gulab.pasha@g7cr.in"

$subject = "Job Failed to Create NewVM - $VMName"

$body = "**************************************************************************************************** `n 
$ErrorMessage `n `n 
$StackTrace `n 
**************************************************************************************************** `n `n 
NewVMRGName = $NewVMRGName `n 
VMName = $VMName`n 
VMLocation = $VMLocation `n 
VMZSize=$VMSize `n 
AdminUserName = $AdminUserName `n 
AdminPassword = $AdminPassword `n 
OSProfile = $OSProfile `n 
SourceImageRGName = $SourceImageRGName `n 
SourceImageName = $SourceImageName `n 
NSGRGName = $NSGRGName `n 
NSGName = $NSGName `n 
CreateVM-ScheduleTime = $ScheduleCVMTime `n 
DestroyVM-ScheduleTime = $ScheduleDVMTime `n
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

        } #Catch Block Closes Here


