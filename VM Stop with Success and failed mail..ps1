
Param
    (
        [Parameter(Mandatory=$true)]
        [String] $VMName,

        [Parameter(Mandatory=$true)]
        [String] $VMRGName
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

try{


        $ErrorActionPreference = "Stop" 


        $vmstatus = (Get-AzureRmVM -Name $VMName -ResourceGroupName $VMRGName -Status).Statuses | Where-Object {$_.Code -like "PowerState/*"}

        

        if($vmstatus.DisplayStatus -eq "VM Running")
        {
          # VM is turned off
          Write-Output "Stopping VM $VMName"
          Stop-AzureRmVM -Name $VMName -ResourceGroupName $VMRGName -Force
          Write-Output "Stopped VM $VMName"


          #Mail Veriables(This executes on failure)
            $Toemailaddress=""
            $From = ""
            $Subject = "VM Stop Information !!!: $((Get-Date).ToShortDateString())"
            $body = "Hello,<br> </br>" 
            $body += "$vmname Has Stopped Successfully.<br> </br>"
            $body += "<br> </br>Regs <br> </br> G7Support <br> </br>"
            $SMTPServer = "outlook.office365.com"
            $SMTPPort = "587"
            
            #Credential for From Mail ID
            $myCredential = Get-AutomationPSCredential -Name 'admin'
            $adminUsername = $myCredential.UserName
            $adminPassword = $myCredential.Password
            $cred = New-Object PSCredential ($adminUsername,$adminPassword)
            
            Write-Output "Mail sent"
            Send-MailMessage -From $From -to $Toemailaddress -Subject $Subject  -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $cred -BodyAsHtml

        }

        Else

        {Write-Output "VM $VMName is already Running"}
}

catch
{
            $err = $_.Exception
            write-output $err.Message
    
            #Mail Veriables(This executes on failure)
            $Toemailaddress=""
            $From = ""
            $Subject = "VM Stop Failed high Importance!!!: $((Get-Date).ToShortDateString())"
            $body = "Hello,<br> </br>" 
            $body += "$vmname Has failed to Start Please check.<br> </br>"
            $body += "<br> </br>Regs <br> </br> G7Support <br> </br>"
            $SMTPServer = "outlook.office365.com"
            $SMTPPort = "587"
 
            #Credential for From Mail ID
            $myCredential = Get-AutomationPSCredential -Name 'admin'
            $adminUsername = $myCredential.UserName
            $adminPassword = $myCredential.Password
            $cred = New-Object PSCredential ($adminUsername,$adminPassword)
 
            Write-Output "Mail sent"
            Send-MailMessage -From $From -to $Toemailaddress -Subject $Subject  -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $cred -BodyAsHtml
}

