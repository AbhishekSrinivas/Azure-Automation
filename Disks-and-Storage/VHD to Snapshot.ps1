
#Login-AzureRmAccount

$Subscriptions = Get-AzureRmSubscription

$storageType = 'Standard_LRS'
$CD = Date
$Time = $CD.ToShortDateString()


Foreach ($Subcription in $Subscriptions)

{

Write-Output $Subcription.Name

$VMS = Get-AzureRMVM


Foreach ($VM in $VMS)

{

$OSDiskSnapshot = $VM.Name + "-OSDisk-" + $Time


if ($VM.StorageProfile.OsDisk.vhd -ne $null)

{

Write-Output "VHD"


$SourceURI = $VM.StorageProfile.OsDisk.Vhd.Uri

$OSDiskSnapshot

    if ($VM.StorageProfile.OsDisk.OsType -eq "Windows")

        {

            $snapshotConfig = New-AzureRmSnapshotConfig -AccountType $storageType -Location $VM.Location `
            -CreateOption Import -SourceUri $SourceURI -OsType Windows

            New-AzureRmSnapshot -Snapshot $snapshotConfig -ResourceGroupName $VM.ResourceGroupName -SnapshotName $OSDiskSnapshot 
         }

    Elseif ($VM.StorageProfile.OsDisk.OsType -eq "Linux") 

        {
        
            $snapshotConfig = New-AzureRmSnapshotConfig -AccountType $storageType -Location $VM.Location `
            -CreateOption Import -SourceUri $SourceURI -OsType Linux

            New-AzureRmSnapshot -Snapshot $snapshotConfig -ResourceGroupName $VM.ResourceGroupName -SnapshotName $OSDiskSnapshot

        }

}


If ($VM.StorageProfile.DataDisks[0].Name -ne $null)

{


    $DataDiskURI0 = $VM.StorageProfile.DataDisks[0].Vhd.Uri
    $DataDiskName0 = $VM.StorageProfile.DataDisks[0].Name + "-" + $Time


            $snapshotConfig = New-AzureRmSnapshotConfig -AccountType $storageType -Location $VM.Location `
            -CreateOption Import -SourceUri $DataDiskURI0

            New-AzureRmSnapshot -Snapshot $snapshotConfig -ResourceGroupName $VM.ResourceGroupName -SnapshotName $DataDiskName0


}


If ($VM.StorageProfile.DataDisks[1].Name -ne $null)

{


    $DataDiskURI1 = $VM.StorageProfile.DataDisks[1].Vhd.Uri
    $DataDiskName1 = $VM.StorageProfile.DataDisks[1].Name + "-" + $Time


            $snapshotConfig = New-AzureRmSnapshotConfig -AccountType $storageType -Location $VM.Location `
            -CreateOption Import -SourceUri $DataDiskURI1

            New-AzureRmSnapshot -Snapshot $snapshotConfig -ResourceGroupName $VM.ResourceGroupName -SnapshotName $DataDiskName1


}

If ($VM.StorageProfile.DataDisks[2].Name -ne $null)

{


    $DataDiskURI2 = $VM.StorageProfile.DataDisks[2].Vhd.Uri
    $DataDiskName2 = $VM.StorageProfile.DataDisks[2].Name + "-" + $Time


            $snapshotConfig = New-AzureRmSnapshotConfig -AccountType $storageType -Location $VM.Location `
            -CreateOption Import -SourceUri $DataDiskURI2

            New-AzureRmSnapshot -Snapshot $snapshotConfig -ResourceGroupName $VM.ResourceGroupName -SnapshotName $DataDiskName2


}

If ($VM.StorageProfile.DataDisks[3].Name -ne $null)

{


    $DataDiskURI3 = $VM.StorageProfile.DataDisks[3].Vhd.Uri
    $DataDiskName3 = $VM.StorageProfile.DataDisks[3].Name + "-" + $Time


            $snapshotConfig = New-AzureRmSnapshotConfig -AccountType $storageType -Location $VM.Location `
            -CreateOption Import -SourceUri $DataDiskURI3

            New-AzureRmSnapshot -Snapshot $snapshotConfig -ResourceGroupName $VM.ResourceGroupName -SnapshotName $DataDiskName3


}


If ($VM.StorageProfile.DataDisks[4].Name -ne $null)

{


    $DataDiskURI4 = $VM.StorageProfile.DataDisks[4].Vhd.Uri
    $DataDiskName4 = $VM.StorageProfile.DataDisks[4].Name + "-" + $Time


            $snapshotConfig = New-AzureRmSnapshotConfig -AccountType $storageType -Location $VM.Location `
            -CreateOption Import -SourceUri $DataDiskURI4

            New-AzureRmSnapshot -Snapshot $snapshotConfig -ResourceGroupName $VM.ResourceGroupName -SnapshotName $DataDiskName4


}

If ($VM.StorageProfile.DataDisks[5].Name -ne $null)

{


    $DataDiskURI5 = $VM.StorageProfile.DataDisks[5].Vhd.Uri
    $DataDiskName5 = $VM.StorageProfile.DataDisks[5].Name + "-" + $Time


            $snapshotConfig = New-AzureRmSnapshotConfig -AccountType $storageType -Location $VM.Location `
            -CreateOption Import -SourceUri $DataDiskURI5

            New-AzureRmSnapshot -Snapshot $snapshotConfig -ResourceGroupName $VM.ResourceGroupName -SnapshotName $DataDiskName5


}




If ($VM.StorageProfile.DataDisks[6].Name -ne $null)

{


    $DataDiskURI6 = $VM.StorageProfile.DataDisks[6].Vhd.Uri
    $DataDiskName6 = $VM.StorageProfile.DataDisks[6].Name + "-" + $Time


            $snapshotConfig = New-AzureRmSnapshotConfig -AccountType $storageType -Location $VM.Location `
            -CreateOption Import -SourceUri $DataDiskURI6

            New-AzureRmSnapshot -Snapshot $snapshotConfig -ResourceGroupName $VM.ResourceGroupName -SnapshotName $DataDiskName6


}

}

}

