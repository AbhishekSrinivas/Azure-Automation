workflow Create-CName-Parallel

{

Param
            (
                [Parameter(Mandatory=$true)]
                [String] $DNSRGName,

                [Parameter(Mandatory=$true)]
                [String] $ZoneName,

                [Parameter(Mandatory=$true)]
                [String] $CName,

                [Parameter(Mandatory=$true)]
                [String] $CNameURL,

                [Parameter(Mandatory=$true)]
                [String] $NoOfCNames
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


foreach -parallel ($i in 1..$NoOfCNames)
    
    {
        InlineScript
            {

$i = $Using:i 
$Name= $Using:CName + $i.ToString("00")
$CCName = "$Name" + $Using:CNameURL


"Creating DNS CName Records - $CCNAME "

    $CN = New-AzureRmDnsRecordSet -Name $Name -RecordType CNAME -ZoneName $Using:ZoneName `
    -ResourceGroupName $Using:DNSRGName -Ttl 3600 -DnsRecords (New-AzureRmDnsRecordConfig `
    -Cname "$CCName") 

    $CN.Name
    $CN.Records
            }
 
    }


}