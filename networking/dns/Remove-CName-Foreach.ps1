Login-AzureRmAccount

Select-AzureRmSubscription -Subscription "ContosoContosoS000"

$RGName = "ContosoMPH-PROD"
$DNSZOne = "contoso.com"
$CName = "mphcontosos001"

foreach ($i in 301..500)
{

    $RCName = $CName + $i
    
    Get-AzureRmDnsRecordSet -Name $RCName -ZoneName $DNSZOne -ResourceGroupName $RGName -RecordType CNAME
    #Remove-AzureRmDnsRecordSet -Name $RCName -RecordType CNAME -ZoneName $DNSZOne -ResourceGroupName $RGName -Force
      

    } 

