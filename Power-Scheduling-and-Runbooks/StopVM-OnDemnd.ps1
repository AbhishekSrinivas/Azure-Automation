Param
    (
       [object] $WebhookData
    )
    
    $WebhookBody = $WebhookData.RequestBody

    $contoso = ConvertFrom-Json -InputObject $WebhookBody

    $VMName = $contoso.VMName
    $ReqByUserID = $contoso.ReqByUserID
 
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

#Log to SQL--Stopping

$Conn = New-Object System.Data.SqlClient.SqlConnection("Server=<sql-server-host>:<sql-server-host>;Database=<database>;User ID=<SQL_USER>;Password=<PASSWORD>;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;TrustServerCertificate=True;")

$Conn.Open() 
$Cmd=new-object system.Data.SqlClient.SqlCommand("exec [Operations].[Proc_ContosoOnStartStopRequestHookUpdate] '$VMName','5','$ReqByUserID'", $Conn) 
$cmd.ExecuteNonQuery(); 
$Conn.Close(); 
#______________________________

            $vm = Get-AzureRmVM

If ($vm.ResourceGroupName -eq $VMName)

    {

"Stopping VM"

        Stop-AzureRmVM -Name $VMName -ResourceGroupName $VMName -Force

"Successfully Stopped VM"
    }
Else
    {
        "VM is Already Stopped or VM is not Found"
    }


#Log to SQL--Stopped

$Conn = New-Object System.Data.SqlClient.SqlConnection("Server=<sql-server-host>:<sql-server-host>;Database=<database>;User ID=<SQL_USER>;Password=<PASSWORD>;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;TrustServerCertificate=True;")

$Conn.Open() 
$Cmd=new-object system.Data.SqlClient.SqlCommand("exec [Operations].[Proc_ContosoOnStartStopRequestHookUpdate] '$VMName','3', '$ReqByUserID'", $Conn) 
$cmd.ExecuteNonQuery(); 
$Conn.Close(); 

#______________________________

"Successfully Deallocated $VMName On-Demand"
"##################################################################################################################"
