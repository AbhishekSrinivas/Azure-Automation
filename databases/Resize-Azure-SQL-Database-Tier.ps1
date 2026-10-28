Param
(
        [Parameter(Mandatory=$true)]
        [String] $ResourceGroupName,

        [Parameter(Mandatory=$true)]
        [String] $ServerName,

        [Parameter(Mandatory=$true)]
        [String] $DatabaseName,

        [Parameter(Mandatory=$true)]
        [String] $Location,

        [Parameter(Mandatory=$true)]
        [String] $NewEdition,
        
        [Parameter(Mandatory=$true)]
        [String]  $NewPricingTier
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

#For DTU:

$ScaleRequest = Set-AzureRmSqlDatabase -DatabaseName $DatabaseName -ServerName $ServerName -ResourceGroupName $ResourceGroupName -Edition $NewEdition -RequestedServiceObjectiveName $NewPricingTier -MaxSizeBytes 

$ScaleRequest

<#For VCore


$ScaleRquestVcore =Set-AzureRmSqlDatabase -DatabaseName "test" -ServerName "idspocbackup" -ResourceGroupName "IDS-POC" -Edition "GeneralPurpose" -ComputeGeneration Gen4 -VCore 2 

$ScaleRquestVcore

#>