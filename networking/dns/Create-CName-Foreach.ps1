#Login-AzureRmAccount

Select-AzureRmSubscription -Subscription "ContosoContosoS000"

$RGName = "ContosoMPH-PROD"
$DNSZOne = "contoso.com"
$CName = "mphcontosos001"

$Region = ".<vm-dns-name>.cloudapp.azure.com"


foreach ($i in 301..500)
{

$Name = $CName + $i
$NCName = $CName + $i + $Region

Write-Output $NCName


New-AzureRmDnsRecordSet -Name $Name -RecordType CNAME -ZoneName "$DNSZOne" `
-ResourceGroupName "$RGName" -Ttl 3600 -DnsRecords (New-AzureRmDnsRecordConfig `
-Cname "$NCName")

}