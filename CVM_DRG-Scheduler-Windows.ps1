Param
    (
       [object] $WebhookData
    )
    
    $WebhookBody = $WebhookData.RequestBody

    $m4l = ConvertFrom-Json -InputObject $WebhookBody

    $NewVMRGName = $m4l.NewVMRGName
    $VMName = $m4l.VMName 
    $VMLocation = $m4l.VMLocation 
    $VMSize = $m4l.VMSize 
    $AdminUserName = $m4l.AdminUserName
    $AdminPassword = $m4l.AdminPassword
    $SourceImageRGName = $m4l.SourceImageRGName
    $SourceImageName = $m4l.SourceImageName
    $SharedResourcesRGName = $m4l.SharedResourcesRGName
    $SubNetName = $m4l.SubnetName
    $VNetName = $m4l.VNetName
    $PublicIPName = $m4l.PublicIPName
    $NICName = $m4l.NICName
    $NSGRGName = $m4l.NSGRGName
    $NSGName = $m4l.NSGName
    $NoOfRetry = $m4l.NoOfRetry
    $ScheduleCVMTime = $m4l.ScheduleCVMTime
    $ScheduleDVMTime = $m4l.ScheduleDVMTime

"#******************************* Login to Azure Run As Connection ********************************************#"

$connectionName = "AzureRunAsConnection"
Try
    {
    
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

"Logging in to Azure..."
            Add-AzureRmAccount -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
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
            }
    }

"#******************************* Successfully Logged in to Azure Run As Connection ********************************#"

$RetryIntervalInSeconds = 10   
$NumberOfRetryAttempts = 2 

Do
    {
        Try
            {
                $ErrorActionPreference = "Stop" 

$ParamCVM = @{ 
            NewVMRGName = $m4l.NewVMRGName;
            VMName = $m4l.VMName; 
            VMLocation = $m4l.VMLocation; 
            VMSize = $m4l.VMSize; 
            AdminUserName = $m4l.AdminUserName;
            AdminPassword = $m4l.AdminPassword;
            SourceImageRGName = $m4l.SourceImageRGName;
            SourceImageName = $m4l.SourceImageName;
            SharedResourcesRGName = $m4l.SharedResourcesRGName;
            SubNetName = $m4l.SubNetName;
            VNetName = $m4l.VNetName;
            PublicIPName = $m4l.PublicIPName;
            NICName = $m4l.NICName;
            NSGRGName = $m4l.NSGRGName;
            NSGName = $m4l.NSGName;
            NoOfRetry = $m4l.NoOfRetry
            }

$ParamDVM = @{
            M4LVMRG = $m4l.NewVMRGName
            }

$Resourcegroup = "M4LAutomation"
$AutoAcc = "M4LAutomationAC"
$RunBookCVM = "CreateVM-Windows"
$RunBookDVM = "DestroyRG"


"Get if any CreateVM Schedule is Exist"

$ErrorActionPreference = "SilentlyContinue" 

$cvmget = Get-AzureRmAutomationSchedule -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc


If ($cvmget.Name -eq $VMName+"CVM") 
   
    {

"Removing Previous CreateVM Schedule..."

            Remove-AzureRmAutomationSchedule -Name ($VMName+"CVM") -ResourceGroupName $Resourcegroup `
            -AutomationAccountName $AutoAcc -Force 

Start-Sleep -Seconds 2

"Creating New CreateVM Schedule..."

            New-AzureRmAutomationSchedule -Name ($VMName+"CVM") -StartTime $ScheduleCVMTime -OneTime `
            -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc 

            Register-AzureRMAutomationScheduledRunbook -RunbookName $RunBookCVM -ScheduleName ($VMName+"CVM") `
            -Parameters $ParamCVM -AutomationAccountName $AutoAcc -ResourceGroupName $Resourcegroup

"CVM Schedule Successfully Created"

    }
else
{"Creating New CreateVM Schedule..."

            New-AzureRmAutomationSchedule -Name ($VMName+"CVM") -StartTime $ScheduleCVMTime -OneTime `
            -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc 

            Register-AzureRMAutomationScheduledRunbook -RunbookName $RunBookCVM -ScheduleName ($VMName+"CVM") `
            -Parameters $ParamCVM -AutomationAccountName $AutoAcc -ResourceGroupName $Resourcegroup

"CreateVM Schedule Successfully Created"

    }

"#***************************************************************************************************************"

"Get if any Destroy ResourceGroup Schedule is Exist"

$dvmget = Get-AzureRmAutomationSchedule -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc

If ($dvmget.Name -eq $VMName+"DVM") 
   
    {
    
"Removing Previous Destroy ResourceGroup Schedule..."

            Remove-AzureRmAutomationSchedule -Name ($VMName+"DVM") -ResourceGroupName $Resourcegroup `
            -AutomationAccountName $AutoAcc -Force 

Start-Sleep -Seconds 2

"Creating New Destroy ResourceGroup Schedule..."

            New-AzureRmAutomationSchedule -Name ($VMName+"DVM") -StartTime $ScheduleDVMTime -OneTime `
            -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc 

            Register-AzureRMAutomationScheduledRunbook -RunbookName $RunBookDVM -ScheduleName ($VMName+"DVM") `
            -Parameters $ParamDVM -AutomationAccountName $AutoAcc -ResourceGroupName $Resourcegroup

"Destroy ResourceGroup Schedule Created"

    }
else 
{
"Creating New Destroy ResourceGroup Schedule..."

            New-AzureRmAutomationSchedule -Name ($VMName+"DVM") -StartTime $ScheduleDVMTime -OneTime `
            -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc 

            Register-AzureRMAutomationScheduledRunbook -RunbookName $RunBookDVM -ScheduleName ($VMName+"DVM") `
            -Parameters $ParamDVM -AutomationAccountName $AutoAcc -ResourceGroupName $Resourcegroup

"Destroy ResourceGroup Schedule Created"

    }


$NumberOfRetryAttempts = -1 
            
            } #Try Closes Here.

Catch 
        {
            
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-output $ErrorMessage
        Write-output $FailedItem

"Start the House Keeping Process"

        $ErrorActionPreference = "SilentlyContinue"

        Remove-AzureRmAutomationSchedule -Name ($VMName +"CVM") -ResourceGroupName $Resourcegroup `
        -AutomationAccountName $AutoAcc -Force

        Remove-AzureRmAutomationSchedule -Name ($VMName +"DVM") -ResourceGroupName $Resourcegroup `
        -AutomationAccountName $AutoAcc -Force
        
Start-Sleep -Seconds 2

"Sending EMail"
$VMName = $m4l.VMName
Write-Output $VMName
$VMLocation = $m4l.VMLocation
Write-Output $VMLocation
$VMSize = $m4l.VMSize
Write-Output $VMSize
$OSProfile = $m4l.OSProfile
Write-Output $OSProfile
$SourceResourceGroup = $m4l.SourceResourceGroup
Write-Output $SourceResourceGroup
$SourceStorageAccName = $m4l.SourceStorageAccName
Write-Output $SourceStorageACCName
$SourceVHDURI = $m4l.SourceVHDURI
Write-Output $SourceVHDURI
$ScheduleCVMTime = $m4l.ScheduleCVMTime
Write-Output $ScheduleCVMTime
$ScheduleDVMTime = $m4l.ScheduleDVMTime
Write-Output $ScheduleDVMTime

$SMTPServer = "smtp.office365.com"
$SMTPPort = "587"
$Username = "m4lsupport@mphasism4l.cloud"
$Password = "Sp1derM@nP0werg7" 
$to = "m4l_admin@g7cr.in"
$cc = 'chris@g7cr.in'

$subject = "Schedule Failed to Create (CVM & DVM)"
$body = ("$ErrorMessage `n",
        "$FailedItem `n",
        "[VMName = $VMName]  `n",
        "[VMLocation = $VMLocation] `n",
        "[VMZSize = $VMSize] `n",
        "[OSProfile = $OSProfile] `n",
        "[SourceResourceGroup = $SourceResourceGroup] `n",
        "[SourceStorageAccountName = $SourceStorageAccName] `n",
        "[SourceVHDURI = $SourceVHDURI] `n",
        "[CreateVM Schedule Time = $ScheduleCVMTime] `n",
        "[Destroy VM ResourceGroup = $ScheduleDVMTime] `n")

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

        }

} while ($RGNumberOfRetryAttempts -ge 0)

"#******************************************************************************************************************#"
