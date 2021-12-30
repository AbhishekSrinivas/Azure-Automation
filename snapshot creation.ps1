$disks=Get-AzureRmDisk | Select Name,Tags,Id,Location,ResourceGroupName ; 
foreach($disk in $disks) 
    { 
        foreach($tag in $disk.Tags) 
            { 
            if($tag.Snapshot -eq 'True') 
                {
                       $snapshotconfig = New-AzureRmSnapshotConfig -SourceUri $disk.Id -CreateOption Copy -Location $disk.Location -AccountType PremiumLRS;$SnapshotName=$disk.Name+(Get-Date -Format "yyyy-MM-dd");
                       New-AzureRmSnapshot -Snapshot $snapshotconfig -SnapshotName $SnapshotName -ResourceGroupName $disk.ResourceGroupName 
                }
        }
    }



