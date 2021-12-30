#Select-AzureRmProfile -Profile C:\Users\gulab\Desktop\m4l.json
#Login-AzureRmAccount
#Select-AzureRmSubscription -SubscriptionName "G7CRM4L001"

$RGName = "G7TSTM4LTemplates-B001"
$Location = "CentralIndia"
$imageName = "m4l00s5_image"
$osVhdUri = "https://testingm4lsa02.blob.core.windows.net/imagetemplates/m4l00s5.vhd"

$imageConfig = New-AzureRmImageConfig -Location $Location
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType Windows -OsState Generalized -BlobUri $osVhdUri

$image = New-AzureRmImage -ImageName $imageName -ResourceGroupName $RGName -Image $imageConfig


