Param
    (
       [object] $WebhookData
    )
    
    $WebhookBody = $WebhookData.RequestBody

    $contoso = ConvertFrom-Json -InputObject $WebhookBody
    
    $VMName = $contoso.VMName 
    $ScheduleDVMTime = $contoso.ScheduleDVMTime

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

$ParamDVM = @{
            ContosoVMRG = $VMName
            }

#Global Variables *******************
$Resourcegroup = "ContosoAutomation"
$AutoAcc = "ContosoAutomationAC"
$RunBookDVM = "DestroyRG"
#************************************

"Get if any Destroy ResourceGroup Schedule is Exist - IF Exist Remove and ReCreate with New Schedule"

$dvmget = Get-AzureRmAutomationSchedule -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc

If ($dvmget.Name -eq $VMName+"DVM") 
   
    {
    
"Removing Previous Destroy ResourceGroup Schedule..."

            Remove-AzureRmAutomationSchedule -Name ($VMName+"DVM") -ResourceGroupName $Resourcegroup `
            -AutomationAccountName $AutoAcc -Force 

"Successcully Completed Removing Previous Destroy ResourceGroup Schedule"

Start-Sleep -Seconds 5

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

        Remove-AzureRmAutomationSchedule -Name ($VMName +"DVM") -ResourceGroupName $Resourcegroup `
        -AutomationAccountName $AutoAcc -Force
        
Start-Sleep -Seconds 2

"Sending EMail"
$VMName = $contoso.VMName
Write-Output $VMName
$ScheduleDVMTime = $contoso.ScheduleDVMTime
Write-Output $ScheduleDVMTime

$SMTPServer = "smtp.office365.com"
$SMTPPort = "587"
$Username = "user@contoso.com"
$Password = "<PASSWORD>" 
$to = "user@contoso.com"
$cc = 'user@contoso.com'

$subject = "DestroyRG Schedule Failed to Recreate"
$body = ("$ErrorMessage `n",
        "$FailedItem `n",
        "[VMName = $VMName]  `n",
        "[DestroyRG Name = $ScheduleDVMTime] `n")

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
