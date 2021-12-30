Param
    (
        [Parameter(Mandatory=$true)]
        [String] $vmname,

        [Parameter(Mandatory=$true)]
        [String] $resourcegroup,

        [Parameter(Mandatory=$true)]
        [String] $vmsize
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

try

{
    $vm = Get-AzureRmVM -ResourceGroupName $resourcegroup -VMName $vmname 
    $size = $vm.HardwareProfile.VmSize

Write-Output "Current VM $size"

if($size -ne $vmsize)
    {
        # VM resize
        Write-Output "Resizing $vmname"
        $size = "$vmsize"
        Stop-AzureRmVM -Name $vmname -ResourceGroupName $resourcegroup -Force
        Update-AzureRmVM -VM $vm -ResourceGroupName $resourcegroup
        Start-AzureRmVM -Name $vmname -ResourceGroupName $resourcegroup
        Write-Output "$vmname Resized"
    }

Else
    
    {Write-Output "VM is already in $size"} 

    #Mail Veriables(This will execute on success)
    $Toemailaddress="akarsh.itigi@g7cr.in; Praleeth.KP@g7cr.in"
    $From = "akarsh.itigi@g7cr.in"
    $Subject = "VM Resize : $((Get-Date).ToShortDateString())"
    $body = "Hello,<br> </br>" 
    $body += "$vmname has been successefully Resized to $vmsize.<br> </br>"
    $body += "<br> </br>Regs <br> </br> G7Support <br> </br>"
    $SMTPServer = "outlook.office365.com"
    $SMTPPort = "587"

    #Credential for From Mail ID
    $myCredential = Get-AutomationPSCredential -Name "credforresize"
    $adminUsername = $myCredential.UserName
    $adminPassword = $myCredential.Password
    $cred = New-Object PSCredential ($adminUsername,$adminPassword)

    Write-Output "Mail sent"
    Send-MailMessage -From $From -to $Toemailaddress -Subject $Subject  -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $cred -BodyAsHtml
}


catch
{
    $err = $_.Exception
    write-output $err.Message
        
    #Mail Veriables(This executes on failure)
    $Toemailaddress="akarsh.itigi@g7cr.in; Praleeth.KP@g7cr.in"
    $From = "NoReply.G7CRAlert@g7cr.in"
    $Subject = "VM Resize Failed high Importance!!!: $((Get-Date).ToShortDateString())"
    $body = "Hello,<br> </br>" 
    $body += "$vmname Has failed to resize to. $vmsize For Customer Beehive Software Services Pvt Ltd Please check.<br> </br>"
    $body += "<br> </br>Regs <br> </br> G7Support <br> </br>"
    $SMTPServer = "outlook.office365.com"
    $SMTPPort = "587"

    #Credential for From Mail ID
    $myCredential = Get-AutomationPSCredential -Name 'credforresize'
    $adminUsername = $myCredential.UserName
    $adminPassword = $myCredential.Password
    $cred = New-Object PSCredential ($adminUsername,$adminPassword)

    Write-Output "Mail sent"
    Send-MailMessage -From $From -to $Toemailaddress -Subject $Subject  -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $cred -BodyAsHtml
}

 