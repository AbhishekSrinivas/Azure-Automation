Param
    (
       [object] $WebhookData
    )
    
    $WebhookBody = $WebhookData.RequestBody

    $m4l = ConvertFrom-Json -InputObject $WebhookBody

    $VMName = $m4l.VMName
    $ReqByUserID = $m4l.ReqByUserID
   
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

$Conn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:mphm4ldbprod.southindia.cloudapp.azure.com;Database=MPHM4LDBPROD;User ID=m4lSPExecuterAzureJobs;Password=M4L!PE*eCuTe!9812;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;TrustServerCertificate=True;") 
$Conn.Open() 
$Cmd=new-object system.Data.SqlClient.SqlCommand("exec [Operations].[Proc_M4LOnStartStopRequestHookUpdate] '$VMName','6', '$ReqByUserID'", $Conn) 
$cmd.ExecuteNonQuery(); 
$Conn.Close(); 
#______________________________

        $vm = Get-AzureRmVM

If ($vm.ResourceGroupName -eq $VMName)

    {
"Starting $VMName On-Demand"

        Start-AzureRmVM -Name $VMName -ResourceGroupName $VMName
 
 "Successfully Started VM"   
    }
Else
    {
        "VM is already Started or VM not Found"
    }

#Log to SQL--Stopped
$Conn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:mphm4ldbprod.southindia.cloudapp.azure.com;Database=MPHM4LDBPROD;User ID=m4lSPExecuterAzureJobs;Password=M4L!PE*eCuTe!9812;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;TrustServerCertificate=True;") 
$Conn.Open() 
$Cmd=new-object system.Data.SqlClient.SqlCommand("exec [Operations].[Proc_M4LOnStartStopRequestHookUpdate] '$VMName', '4','$ReqByUserID'", $Conn) 
$cmd.ExecuteNonQuery(); 
$Conn.Close(); 
#______________________________

"Successfully Started $VMName On-Demand"
"############################################################################################################"
