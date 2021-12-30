Login-AzureRmAccount

Select-AzureRmSubscription -Subscription "G7CRM4LS000"

$RGName = "M4LMPH-PROD"
$DNSZOne = "mphasism4l.cloud"
$CName = "mphm4ls001"

foreach ($i in 301..500)
{

    $RCName = $CName + $i
    
    Get-AzureRmDnsRecordSet -Name $RCName -ZoneName $DNSZOne -ResourceGroupName $RGName -RecordType CNAME
    #Remove-AzureRmDnsRecordSet -Name $RCName -RecordType CNAME -ZoneName $DNSZOne -ResourceGroupName $RGName -Force
      

    } 

