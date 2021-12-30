 Param
(
        [Parameter(Mandatory=$true)]
        [String] $ApplicationGatewayName,

        [Parameter(Mandatory=$true)]
        [String] $ResourceGroupName,

        [Parameter(Mandatory=$true)]
        [String]  $Name,
        
        [Parameter(Mandatory=$true)]
        [String]  $NewTier,

        [Parameter(Mandatory=$true)]
        [UInt32]  $IntanceCapacity
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

$AppGwExisting = Get-AzureRmApplicationGateway -Name $ApplicationGatewayName -ResourceGroupName $ResourceGroupName

$AppGwExisting.Sku

$AppGwUpdatedSku = Set-AzureRmApplicationGatewaySku -ApplicationGateway $AppGwExisting -Name $Name -Tier $NewTier -Capacity $IntanceCapacity

$UpdatedAppGw = Set-AzureRmApplicationGateway -ApplicationGateway $AppGwExisting

$UpdatedAppGw.Sku




<#
-Name :    The acceptable values for this parameter are:

Standard_Small
Standard_Medium
Standard_Large
WAF_Medium
WAF_Large


-Tier   :  Accepted values:	Standard, WAF, Standard_v2, WAF_v2

#>