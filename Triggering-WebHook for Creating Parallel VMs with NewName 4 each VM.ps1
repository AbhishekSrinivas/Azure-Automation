#Webhook for Triggering Parallel VMs with New Name for each VM from Managed Image

$Params = @( @{NewVMName01='ArunDVM';
                NewVMName02='ChrisDVM';
                NewVMName03='NehaDVM';
                NewVMName04='JesDVM';
                NewVMName05='SurabhiDVM';
                NewVMName06='HariDVM';
		NewVMName07='JesDVM';
                NewVMName08='sonaliDVM';
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
                AdminPassword='P@ssw0rd@123';
                DataDSKSize='5'} )

$body = ConvertTo-Json -InputObject $Params
$WHURI = "https://s7events.azure-automation.net/webhooks?token=yF6TEpWeX1nUplyv%2bxVzPscRTxbNB3is9ND4XGwtKGA%3d"

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
                AdminPassword='P@ssw0rd@123';
                NoofVMs='100';
                DataDSKSize='5'} )

$body = ConvertTo-Json -InputObject $Params
$WHURI = "https://s7events.azure-automation.net/webhooks?token=eMkKkRFZvFZjdZqM3wRaiahISR%2frCBp1W%2fZ%2fRhyq6zQ%3d"

Invoke-RestMethod -Uri $WHURI -Method Post -Body $body

#===========================================================================================================================