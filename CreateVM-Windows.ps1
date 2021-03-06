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
        [String] $SourceImageRGName,

        [Parameter(Mandatory=$true)]
        [String] $SourceImageName,

        [Parameter(Mandatory=$true)]
        [String] $SharedResourcesRGName,

        [Parameter(Mandatory=$true)]
        [String] $SubnetName,

        [Parameter(Mandatory=$true)]
        [String] $VNetName,

        [Parameter(Mandatory=$true)]
        [String] $PublicIPName,

        [Parameter(Mandatory=$true)]
        [String] $NICName,

        [Parameter(Mandatory=$true)]
        [String] $NSGRGName,

        [Parameter(Mandatory=$true)]
        [String] $NSGName,

        [Parameter(Mandatory=$true)]
        [String] $NoOfRetry
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

"Create ResourceGroup for $VMName"

        New-AzureRmResourceGroup -Name $NewVMRGName -Location $VMLocation -Force

"Successfully Created ResourceGroup" 

        $image = Get-AzureRMImage -ImageName $SourceImageName -ResourceGroupName $SourceImageRGName

"Associating Network Security Group with Network Intrface Card"

        $nic = Get-AzureRmNetworkInterface -Name $NICName -ResourceGroupName $SharedResourcesRGName

        $nsg = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $NSGRGName   

        $nic.NetworkSecurityGroup = $nsg
 
        Set-AzureRmNetworkInterface -NetworkInterface $nic


"Add and Set New VMSize, OS Profile and Credentials to $VMName"

        $cred = New-Object PSCredential $AdminUserName, ($AdminPassword | ConvertTo-SecureString -AsPlainText -Force)

        $ComputerName = $VMName
        
        $vm = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize

        $vm = Set-AzureRmVMSourceImage -VM $vm -Id $image.Id

"Configuring $VMName for Windows Environment"
       
        $vm = Set-AzureRmVMOSDisk -VM $vm -StorageAccountType StandardLRS -CreateOption FromImage -Windows `
        -Caching ReadWrite

        $vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $ComputerName -Credential $cred -ProvisionVMAgent

"Associating Network Interface Card with NewVM"

        $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
        
"Network Interface Card Successfully Associated with NewVM"

        $vm = Set-AzureRmVMBootDiagnostics -VM $vm -Disable

"Adding the Config to an VM Array and Creating NewVM - $VMName - Please Wait ...................."

        New-AzureRmVM -VM $vm -ResourceGroupName $NewVMRGName -Location $VMLocation

"Successfully Deployed NewVM - $VMName"

"Deallocate the VM and Exit the Job"

            Stop-AzureRmVM -Name $VMName -ResourceGroupName $NewVMRGName -Force

"Successfully Deallocated NewVM - $VMName - NewVM is Ready to USE"

"Updating the NewVM Creation Success info to SQL SP"

$Conn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:mphm4ldbprod.southindia.cloudapp.azure.com;Database=MPHM4LDBPROD;User ID=m4lSPExecuterAzureJobs;Password=M4L!PE*eCuTe!9812;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;TrustServerCertificate=True;")

        $Conn.Open() 
        $Cmd=new-object system.Data.SqlClient.SqlCommand("exec [Operations].[Proc_UpdateDBOnMachineCreation] '$VMName','1'", $Conn) 
        Invoke-AARUScriptBlock -ScriptBlock{ $cmd.ExecuteNonQuery(); } -Retries 3 -RetryInterval 20
        $Conn.Close();

"VM Creation Job Completed Sucesfully"
      
            } #Try Block Closes Here

Catch
    {
        
            write-output "Exception Caught..."  
            $ErrorMessage = $_.Exception.Message   
            $StackTrace = $_.Exception.StackTrace   
            Write-Output "Error Occurred: Message: $ErrorMessage, stack: $StackTrace." 

            Remove-AzureRmResourceGroup -Name $NewVMRGName -Force

$Resourcegroup = "M4LAutomation"
$AutoAcc = "M4LAutomationAC"

$GetSCHTime = Get-AzureRmAutomationSchedule -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoACC | select Name,StartTime

$ScheduleCVMTime = $GetSCHTime | where { $_.name -eq $VMName+"CVM" } | select StartTime
$ScheduleDVMTime = $GetSCHTime | where { $_.name -eq $VMName+"DVM" } | select StartTime 

"Sending EMail for Support Ticket to Create VM"

$SMTPServer = "smtp.office365.com"
$SMTPPort = "587"
$Username = "m4lsupport@mphasism4l.cloud"
$Password = "Sp1derM@nP0werg7" 
$to = "m4l_admin@g7cr.in"
$cc = 'chris@g7cr.in'

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
OSProfile = Windows `n 
SourceImageRGName = $SourceImageRGName `n 
SourceImageName = $SourceImageName `n 
SharedResourcesRGName = $SharedResourcesRGName `n 
SubNetName = $SubNetName `n 
VNetName = $VNetName `n 
PublicIPName = $PublicIPName `n 
NICName = $NICName `n 
NSGRGName = $NSGRGName `n 
NSGName = $NSGName `n 
NoOfRetry = $NoOfRetry `n 
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


