Param
(
  [Parameter(Mandatory=$true)]
  [String] $ContosoVMRG
)

"#******************************* Login to Azure Run As Connection ********************************************#"

  $connectionName = "AzureRunAsConnection"
    
Try
    {
    
# Get the connection "AzureRunAsConnection "
        
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
            }
    }
"#******************************* Successfully Logged in to Azure Run As Connection ********************************#"

Try 
        {

#************************************
#Global Varialbes  
$Resourcegroup = "ContosoAutomation"
$AutoAcc = "ContosoAutomationAC"
$VMName = $ContosoVMRG
#************************************

"Get The ResourceGroup Name to Remove"

$RG = Get-AzureRmResourceGroup

If ($RG.ResourceGroupName -eq $ContosoVMRG)

    {
    "Removing ResourceGroup - $ContosoVMRG"

        Remove-AzureRmResourceGroup -Name $ContosoVMRG -Force
    
    "Successfully Removed ResouceGroup - $ContosoVMRG"

    "#Log to SQL on Successfull removing RG"
      
      $Conn = New-Object System.Data.SqlClient.SqlConnection("Server=<sql-server-host>:<sql-server-host>;Database=<database>;User ID=<SQL_USER>;Password=<PASSWORD>;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;TrustServerCertificate=True;")

      $Conn.Open() 
      $Cmd=new-object system.Data.SqlClient.SqlCommand("exec [Operations].[Proc_ContosoOnRGDeleteHookUpdate] '$ContosoVMRG'", $Conn) 
      $cmd.ExecuteNonQuery(); 
      $Conn.Close();
      "Log To SQL Sucesfull_________________________________________________________________"
      
    }
Else 

    {
        "No ResourceGroup Found to Remove"
    }

"House Keeping Remove the Schedule from the ContosoMachineCreator and ContosoMachineDestructor runbooks"

$cvmget = Get-AzureRmAutomationSchedule -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc

If ($cvmget.Name -eq $VMName+"CVM") 
    {
        "Removing Create VM Schedules"

            Remove-AzureRmAutomationSchedule -Name ($VMName+"CVM") `
            -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc -Force  
          
        "Successfully Completed Removing Schedule for CreateVM"

         "#Log to SQL on Successfull removing RG"
      $Conn = New-Object System.Data.SqlClient.SqlConnection("Server=<sql-server-host>:<sql-server-host>;Database=<database>;User ID=<SQL_USER>;Password=<PASSWORD>;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;TrustServerCertificate=True;")

      $Conn.Open() 
      $Cmd=new-object system.Data.SqlClient.SqlCommand("exec [Operations].[Proc_ContosoOnRGDeleteHookUpdate] '$VMName'", $Conn) 
      $cmd.ExecuteNonQuery(); 
      $Conn.Close();
      "Log To SQL Sucesfull_________________________________________________________________"
    }
Else 
    {

        "No CreateVM Schedule Found"

    }

$dvmget = Get-AzureRmAutomationSchedule -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc

If ($dvmget.Name -eq $ContosoVMRG+"DVM") 
    {
        "Removing Detroy ResourceGroup Schedule"
        
            Remove-AzureRmAutomationSchedule -Name ($VMName+"DVM") `
            -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc -Force

        "Successfully Completed Removing Schedule for Destroy ResourceGroup"

         "#Log to SQL on Successfull removing RG"
      $Conn = New-Object System.Data.SqlClient.SqlConnection("Server=<sql-server-host>:<sql-server-host>;Database=<database>;User ID=<SQL_USER>;Password=<PASSWORD>;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;TrustServerCertificate=True;")
      
      $Conn.Open() 
      $Cmd=new-object system.Data.SqlClient.SqlCommand("exec [Operations].[Proc_ContosoOnRGDeleteHookUpdate] '$VMName'", $Conn) 
      $cmd.ExecuteNonQuery(); 
      $Conn.Close();
      "Log To SQL Sucesfull_________________________________________________________________"
    }
Else 
    {

        "No Destroy ResourceGroup Schedule Found"

    }

"******************************* Program Exited WITH SUCCESS ***********************************************"
        }

Catch 
        {

"In Catch Block"

$ErrorMessage = $_.Exception.Message   
$StackTrace = $_.Exception.StackTrace  
$FailedItem = $_.Exception.ItemName                  
		                        
"House Keepig..."
                $RG = Get-AzureRmResourceGroup
                $RG.ResourceGroupName
          
"Sending EMail"

"#******************************************************************************************************************"

Write-Output $ContosoVMRG

"#******************************************************************************************************************"

$SMTPServer = "smtp.office365.com"
$SMTPPort = "587"
$Username = "user@contoso.com"
$Password = "<PASSWORD>" 
$to = "user@contoso.com"
$cc = 'user@contoso.com'

$subject = "Schedule Failed to Create (CVM & DVM)"
$body = ("Error Message: $ErrorMessage `n",
         "$FailedItem `n",
         "[VMRGName = $ContosoVMRG] `n")
        
$message = New-Object System.Net.Mail.MailMessage
$message.subject = $subject
$message.body = $body
$message.to.add($to)
$message.cc.add($cc)

$message.from = $username
<#$message.attachments.add($attachment)#>

$smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort);
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
$smtp.send($message)
write-output "Mail Sent" 
"#******************************************************************************************************************"
}
