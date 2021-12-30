
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

$ErrorActionPreference = "Stop" 

$day = (Get-Date).DayOfWeek
    if ($day -eq 'sunday'){
        exit
}

$vmstatus = (Get-AzureRmVM -Name $VMName -ResourceGroupName $VMRGName -Status).Statuses | Where-Object {$_.Code -like "PowerState/*"}

Write-Output "VM Status $($vmstatus.DisplayStatus)"

if($vmstatus.DisplayStatus -eq "VM Running")
{
  # VM is turned off
  Write-Output "Stopping VM $VMName"
  Stop-AzureRmVM -Name $VMName -ResourceGroupName $VMRGName -Force
  Write-Output "Stopped VM $VMName"
}

Else

{Write-Output "VM is already Stopped"}
