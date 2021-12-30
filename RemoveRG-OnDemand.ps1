 Param
    (
       [object] $WebhookData
    )
    
    $WebhookBody = $WebhookData.RequestBody

    $m4l = ConvertFrom-Json -InputObject $WebhookBody
    $RGName = $m4l.RGName

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

#************************************
#Global Variables"
$Resourcegroup = "M4LAutomation"
$AutoAcc = "M4LAutomationAC"
#************************************


"WebHook is Triggered to Remove $RGName - Resource Group, CreateVM Schedule and Destroy ResourceGroup Schedule"

"#******************************************************************************************************************#"

$RGName1 = Get-AzureRmResourceGroup
    
        if ($RGName1.ResourceGroupName -eq $RGName)
            
            {
                "ResourceGroup Exists, Will Remove it Right Away"
               
                Remove-AzureRmResourceGroup -Name $RGName -Force

                Start-Sleep -Seconds 20
                 
            }
        else
            {
                   "No ResourceGroup Found"
            }

"#******************************************************************************************************************#"           

"Get if any Create NewVM Schedule is Exist"

$CVMGet = Get-AzureRmAutomationSchedule -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc

If ($CVMGet.Name -eq $RGName+"CVM") 

    {
"Removing Previous CVM Schedule..."

        Remove-AzureRmAutomationSchedule -Name ($RGName+"CVM") -ResourceGroupName $Resourcegroup `
        -AutomationAccountName $AutoAcc -Force 
    }
Else
    {
        "No Create VM Schedule Found"
    }

"#******************************************************************************************************************#"

"Get if any Destroy ResourceGroup Schedule is Exist"
$DVMGet = Get-AzureRmAutomationSchedule -ResourceGroupName $Resourcegroup -AutomationAccountName $AutoAcc 

If ($DVMGet.Name -eq $RGName+"DVM")

    {
    
"Removing Previous Destroy ResourceGroup Schedule..."

        Remove-AzureRmAutomationSchedule -Name ($RGName+"DVM") -ResourceGroupName $Resourcegroup `
        -AutomationAccountName $AutoAcc -Force 
    }
Else

    {
        "No Destory ResourceGroup Schedule Found"
    }

"#******************************************************************************************************************#"


#Log to SQL on Successfull Removing RG
$Conn = New-Object System.Data.SqlClient.SqlConnection("Server=tcp:mphm4ldbprod.southindia.cloudapp.azure.com;Database=MPHM4LDBPROD;User ID=m4lSPExecuterAzureJobs;Password=M4L!PE*eCuTe!9812;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;TrustServerCertificate=True;")

$Conn.Open() 
$Cmd=new-object system.Data.SqlClient.SqlCommand("exec [Operations].[Proc_M4LOnRGDeleteHookUpdate] '$RGName'", $Conn) 
$cmd.ExecuteNonQuery(); 
$Conn.Close();



"#******************************************************************************************************************#"


