Param
 
    (
 
        [Parameter(Mandatory=$true)]
 
        [String] $VMName,
 
        [Parameter(Mandatory=$true)]
 
        [String] $VMRGName
 
    )
 
 try
{
 
"#******************************* Login to Azure Run As Connection ********************************************#"
$connectionName = "AzureRunAsConnection"
 
$ErrorActionPreference="Stop"
Write-Output "Trying to Login"

$Credentials = Get-AutomationPSCredential -Name "admin"
$subscriptionId ='be111d60-31a6-4556-9566-c6aec70d5872' #‘{your subscriptionId}’
$SubtenantId ='9fc3e888-8be3-44fc-adc6-c886252a51d7' #‘{your tenantId}’
Login-AzureRmAccount -Credential $Credentials -SubscriptionId $subscriptionId -TenantId $SubtenantId 
 
"#******************************* Successfully Logged in to Azure Run As Connection ********************************#"
 
$ErrorActionPreference = "Stop" 
 
$day = (Get-Date).DayOfWeek
 
    if ($day -eq 'Sunday'){
 
        exit
 
}
 
$vmstatus = (Get-AzureRmVM -Name $VMName -ResourceGroupName $VMRGName -Status).Statuses | Where-Object {$_.Code -like "PowerState/*"}
 
if($vmstatus.DisplayStatus -eq "VM Deallocated")
 
{
 
  # VM is turned off
 
  Write-Output "Starting VM $VMName"
 
  Start-AzureRmVM -Name $VMName -ResourceGroupName $VMRGName
 
  Write-Output "Started VM $VMName"
 
}
 
Else
 
{Write-Output "VM $VMName is already Running"}
 
}
 
catch
{
$err = $_.Exception
write-output $err.Message
    
#Mail Veriables(This executes on failure)
$Toemailaddress="akarsh.itigi@g7cr.in"
$From = "NoReply.G7CRAlert@g7cr.in"
$Subject = "VM Start Failed high Importance!!!: $((Get-Date).ToShortDateString())"
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