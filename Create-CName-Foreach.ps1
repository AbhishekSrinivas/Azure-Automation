#Login-AzureRmAccount

Select-AzureRmSubscription -Subscription "G7CRM4LS000"

$RGName = "M4LMPH-PROD"
$DNSZOne = "mphasism4l.cloud"
$CName = "mphm4ls001"

$Region = ".westindia.cloudapp.azure.com"


foreach ($i in 301..500)
{

$Name = $CName + $i
$NCName = $CName + $i + $Region

Write-Output $NCName


New-AzureRmDnsRecordSet -Name $Name -RecordType CNAME -ZoneName "$DNSZOne" `
-ResourceGroupName "$RGName" -Ttl 3600 -DnsRecords (New-AzureRmDnsRecordConfig `
-Cname "$NCName")

}