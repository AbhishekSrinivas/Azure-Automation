Select-AzureRmProfile -Profile C:\Users\user\Desktop\contoso.json
#Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName "ContosoContoso08"

$RGName = "ContosoTemplates"
$Location = "SouthIndia"
$imageName = "contoso01s2_img2"
$osVhdUri = $SA.PrimaryEndpoints.Blob.ToString() + "templates/contoso01s2.vhd"

$imageConfig = New-AzureRmImageConfig -Location $Location
$imageConfig = Set-AzureRmImageOsDisk -Image $imageConfig -OsType Linux -OsState Generalized -BlobUri $osVhdUri

$image = New-AzureRmImage -ImageName $imageName -ResourceGroupName $RGName -Image $imageConfig


