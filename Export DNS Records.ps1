#Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "Microsoft Azure"


$results = @()

$Resources

$file = "C:\Users\gulab\Desktop\teamlease.com.csv"

$RGName = "teamlease-dns-rg"
$DNSZone = "teamlease.com"

$DNS = Get-AzureRmDnsZone 

$Records = Get-AzureRmDnsRecordSet -ZoneName $DNSZone -ResourceGroupName $RGName

Foreach ($Record in $Records)

{


$details  = @{ 
                'RecordName'= $Record.Name
                'RecordType' = $Record.Records.Ipv4Address
                'ZoneName' = $Record.ZoneName
                'RecordTypes' = $Record.RecordType


                }

            $results += New-Object PSObject -Property $details
}


$results | Select "RecordName","RecordType","ZoneName","RecordTypes" | Export-Csv -Path $file