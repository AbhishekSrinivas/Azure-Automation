#Select-AzureRmProfile -Profile C:\Users\user\Desktop\contoso.json
#Login-AzureRmAccount
#Select-AzureRmSubscription -SubscriptionName "ContosoContoso001"

$RGName = "ContosoTSTContosoTemplates-B001"
$Location = "CentralIndia"
$imageName = "contoso00s5_image"
$osVhdUri = "https://<storage-account>.blob.core.windows.net/imagetemplates/contoso00s5.vhd"

$imageConfig = New-AzureRmImageConfig -Location $Location
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType Windows -OsState Generalized -BlobUri $osVhdUri

$image = New-AzureRmImage -ImageName $imageName -ResourceGroupName $RGName -Image $imageConfig


