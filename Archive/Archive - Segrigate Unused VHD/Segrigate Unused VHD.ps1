Login-AzureRmAccount

$subs = (Get-AzureRmSubscription).Name

$VM = @()

foreach ($sub in $subs)
{

    Select-AzureRmSubscription -SubscriptionName "$sub"
    
    $RG= Get-AzureRmResourceGroup

    $RGS=$RG.ResourceGroupName

    foreach ($R in $RGS)

        {   
        
        $VMS= Get-AzureRmVM -ResourceGroupName $R
        $VM +=$VMS
        }

}

$VM | Export-Csv -Path C:\Users\Jerry\Desktop\Mobius\vm.csv

$StorageProfile = $VM.StorageProfile

$osdisk= $VM.StorageProfile.OsDisk
$osdisk | Export-Csv -Path C:\Users\Jerry\Desktop\Mobius\osdisk.csv

$vhd= $VM.StorageProfile.OsDisk.vhd

$vhd | Export-Csv -Path C:\Users\Jerry\Desktop\Mobius\vhd.csv

$VM| Ft vmname,storageaccount,location

$vmdetail =@()

$name = @()
$vhdname =@()

foreach ($v in $VM)

{
$vhd= $v.StorageProfile.OsDisk.vhd

if ($vhd -ne $null)
 {
 $name += $v.name
 #$name = $v.name
 #$vmname += $name
 $vhdname += $v.StorageProfile.OsDisk.vhd
 #$vdname = $v.StorageProfile.OsDisk.vhd 
 #$vhdname += $vdname
 }

}

$name | Export-Csv -Path C:\Users\Jerry\Desktop\Mobius\vmname.csv

$vhdname | Export-Csv -Path C:\Users\Jerry\Desktop\Mobius\vhdname.csv

######################################################################

$OSDiskPath=(Get-AzureRmVM -ResourceGroupName $rgName -Name $VM.Name).StorageProfile.OSDisk.Vhd.Uri
if($OSDiskPath -eq $null)
{
$OSDiskPath=(Get-AzureRmVM -ResourceGroupName $rgName -Name $VM.Name).StorageProfile.OSDisk.ManagedDisk.Id
}
#Data Disk Path
$DataDiskPath=(Get-AzureRmVM -ResourceGroupName $rgName -Name $VM.Name).StorageProfile.DataDisks.Vhd.Uri
if($DataDiskPath -eq $null)
{
$DataDiskPath=@()
$DataDiskPath+=(Get-AzureRmVM -ResourceGroupName $rgName -Name $VM.Name).StorageProfile.DataDisks.ManagedDisk.Id
$dd="$DataDiskPath"
}
else
{
$dd=(Get-AzureRmVM -ResourceGroupName $rgName -Name $VM.Name).StorageProfile.DataDisks.ManagedDisk.Id
}  