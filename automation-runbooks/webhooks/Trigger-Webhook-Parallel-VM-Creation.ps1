#Webhook for Triggering Parallel VMs with New Name for each VM from Managed Image

$Params = @( @{NewVMName01='ArunDVM';
                NewVMName02='UserDVM';
                NewVMName03='NehaDVM';
                NewVMName04='JesDVM';
                NewVMName05='SurabhiDVM';
                NewVMName06='HariDVM';
		NewVMName07='JesDVM';
                NewVMName08='userDVM';
                NewVMName09='ROSEDVM';
                NewVMName10='LILYDVM';
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

#===========================================================================================================================

#Webhook for Triggering Parallel No of VMs from Managed Image

$Params = @( @{NewVMName='ArunDVM';
                VMLocation='CentralIndia';
                VMSize='Standard_DS1_V2';
                OSProfile='Windows';
                SourceImageRGName='DemoLNXSnap';
                SourceImageName='image';
               	VNet_AddPrefix='10.0.0.0/16';
                Subnet_AddPrefix='10.0.0.0/24';
                AdminUserName='labadmin';
                AdminPassword='<PASSWORD>';
                NoofVMs='100';
                DataDSKSize='5'} )

$body = ConvertTo-Json -InputObject $Params
$WHURI = "https://<automation-webhook-host>.azure-automation.net/webhooks?token=<WEBHOOK_TOKEN>"

Invoke-RestMethod -Uri $WHURI -Method Post -Body $body

#===========================================================================================================================