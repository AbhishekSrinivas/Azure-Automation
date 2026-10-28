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


$days = Get-Date

$day = $days.DayOfWeek

$day

If ($day -eq "Saturday")

    {Write-Output "Today is Weekoff"}

        ElseIf ($day -eq "Sunday")

            {Write-Output "Today is Weekoff"}

Else {

        Start-AzureRMVM -Name $VMName -ResourceGroupName $VMRGName

        Write-Output "$VMName is Starting as it weekday"

        }