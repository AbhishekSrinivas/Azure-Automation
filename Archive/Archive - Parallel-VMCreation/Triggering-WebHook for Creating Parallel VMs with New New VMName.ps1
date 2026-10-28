
$Params = @( @{NewVMName01='ArunDVM';
                NewVMName02='UserDVM';
                NewVMName03='NehaDVM';
                NewVMName04='JesDVM';
                NewVMName05='SurabhiDVM';
                NewVMName06='HariDVM';
                VMLocation='CentralIndia';
                VMSize='Standard_DS1_V2';
                OSProfile='Windows';
                SourceImageRGName='DemoLNXSnap';
                SourceImageName='image';
               	VNet_AddPrefix='10.0.0.0/16';
                Subnet_AddPrefix='10.0.0.0/24';
                AdminUserName='labadmin';
                AdminPassword='<PASSWORD>';
                DataDSKSize='5'} )

$body = ConvertTo-Json -InputObject $Params
$WHURI = "https://<automation-webhook-host>.azure-automation.net/webhooks?token=<WEBHOOK_TOKEN>"

Invoke-RestMethod -Uri $WHURI -Method Post -Body $body
