param (
            [parameter(Mandatory=$true)]
            [String]$resourceGroupName,
         
            [Parameter(Mandatory = $true)]
            [String]$WebAppName
        )


 "#******************************* Login to Azure Run As Connection ********************************************#"
$connectionName = "AzureRunAsConnection"
 
Try
{
        $ErrorActionPreference="Stop"
        Write-Output "Trying to Login"

        $Credentials = Get-AutomationPSCredential -Name "noreplay"
        $subscriptionId ='e5b99a27-b0a3-4086-bb8a-3627977343ad' #‘{your subscriptionId}’
        $SubtenantId ='8cf062ed-12f4-42f6-97ed-0bbbd6a3fae5' #‘{your tenantId}’
        Login-AzureRmAccount -Credential $Credentials -SubscriptionId $subscriptionId -TenantId $SubtenantId 


        Write-Output "Logged IN successfully"

"#******************************* Successfully Logged in to Azure Run As Connection ********************************#"

    Restart-AzureRmWebApp -ResourceGroupName $resourceGroupName -Name $WebAppName

    <#
        #Mail Veriables(This will execute on success)
           $Toemailaddress="akarsh.itigi@g7cr.in","cloudsupport@g7cr.in"
        $From = "NoReply.G7CRAlert@g7cr.in"
        $Subject = "Web App Restart : $((Get-Date).ToShortDateString())"
        $body = "Hello,<br> </br>" 
        $body += "Web App $WebAppName Restart successfully.<br> </br>"
        $body += "<br> </br>Regs <br> </br> G7Support <br> </br>"
        $SMTPServer = "outlook.office365.com"
        $SMTPPort = "587"

        #Credential for From Mail ID
        $myCredential = Get-AutomationPSCredential -Name 'noreplay'
        $adminUsername = $myCredential.UserName
        $adminPassword = $myCredential.Password
        $cred = New-Object PSCredential ($adminUsername,$adminPassword)

        Write-Output "Mail sent"
        Send-MailMessage -From $From -to $Toemailaddress -Subject $Subject  -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $cred -BodyAsHtml
        #>
}

catch
{
        $err = $_.Exception
        write-output $err.Message
    
        #Mail Veriables(This executes on failure)
        $Toemailaddress="akarsh.itigi@g7cr.in","cloudsupport@g7cr.in"
        $From = "NoReply.G7CRAlert@g7cr.in"
        $Subject = "Web App Restart Failed high Importance!!! : $((Get-Date).ToShortDateString())"
        $body = "Hello,<br> </br>" 
        $body += "Web App $WebAppName Restart Failed for Customer: ExtraaEdge Technology Solutions Private Limited: $subscriptionId. Please check.<br> </br>"
        $body += "<br> </br>Regs <br> </br> G7Support <br> </br>"
        $SMTPServer = "outlook.office365.com"
        $SMTPPort = "587"

        #Credential for From Mail ID
        $myCredential = Get-AutomationPSCredential -Name 'noreplay'
        $adminUsername = $myCredential.UserName
        $adminPassword = $myCredential.Password
        $cred = New-Object PSCredential ($adminUsername,$adminPassword)

        Write-Output "Mail sent"
        Send-MailMessage -From $From -to $Toemailaddress -Subject $Subject  -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $cred -BodyAsHtml
}

