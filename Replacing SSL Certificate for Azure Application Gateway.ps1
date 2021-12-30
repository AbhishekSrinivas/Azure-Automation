#Login-AzureRmAccount

Select-AzureRmSubscription -Subscription "PROD"

$RGName = "hrbmainsiteVMRG"
$AppGateway = "HRBlockMainSite-AppGW"

$OldSSLCertName = "hrblock"
$NewName = "hrblock"

$NewSSLCert = "C:\Users\Gulab\OneDrive - G7 CR Technologies India Pvt Ltd\Client- WebSites & Access Credentials\Sites\H&R Block\STAR_hrblock_in - NewCert\STAR_hrblock_in\hrblock.pfx"

$APG = Get-AzureRmApplicationGateway -Name $AppGateway -ResourceGroupName $RGName

$SSL = Get-AzureRmApplicationGatewaySslCertificate -ApplicationGateway $APG

Set-AzureRmApplicationGatewaySslCertificate -ApplicationGateway $APG -Name $NewName -CertificateFile $NewSSLCert

Start-Sleep -Seconds 900


Set-AzureRmApplicationGateway -ApplicationGateway $APG

