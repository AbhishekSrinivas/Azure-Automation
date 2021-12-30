Login-AzureRmAccount 

Select-AzureRmSubscription -SubscriptionName "G7CR Training"

$IAMName = "IAM_G7"

$VMlists = Import-Csv -Path "C:\Users\Gulab\Desktop\VMList.csv"

foreach ($VMList in $VMlists)

{

$VMName = $VMList.VMName
$RGName = $VMList.RGName
$UserName = $VMList.Username


Write-Output "VMName - $VMName"
Write-Output "RGName - $RGName"
Write-Output "Username - $UserName"

$Resource = Get-AzureRmResource -ResourceType "Microsoft.Compute/virtualMachines" -Name "$VMName"


New-AzureRmRoleAssignment -SignInName $UserName `
                            -RoleDefinitionName $IAMName `
                            -ResourceGroupName $RGName `
                            -ResourceName $VMName -ResourceType $Resource.ResourceType



}



$VMlists = Import-Csv -Path "C:\users\Gulab\Desktop\VMList.csv"

$DiskRGName = "TrainingImageNetwork-RG"
$DiskName = ""



Foreach ($VMList in $VMlists)

{

$VMName = $VMList.VMName
$RGName = $VMList.RGName

$managedDisk= Get-AzureRMDisk -ResourceGroupName $DiskRGName -DiskName $DiskName

$diskConfig = New-AzureRmDiskConfig -SourceResourceId $managedDisk.Id -Location $managedDisk.Location -CreateOption Copy
New-AzureRmDisk -Disk $diskConfig -DiskName "$RGName-DataDisk" -ResourceGroupName $RGName

$vm = Get-AzureRMVM -ResourceGroupName $RGName -Name $VMName
$DDisk = Get-AzureRmDisk -ResourceGroupName $RGName -DiskName "$RGName-DataDisk"

Add-AzureRmVMDataDisk -VM $vm -Name $DDisk.Name -Lun 0 -ManagedDiskId $DDisk.Id -Caching None -CreateOption "attach"
Update-AzureRmVM -ResourceGroupName $RGName -VM $vm


}


