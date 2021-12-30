
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
            $SourceOSURI = $VM.StorageProfile.OsDisk.ManagedDisk
            $OSDiskSnapshot = $VM.StorageProfile.OsDisk.Name + "-OSDiskBackup-" + $Time

            If ($VM.StorageProfile.OsDisk.ManagedDisk -ne $null)

            {
                $VM.Name
                $Count = ($VM.StorageProfile.DataDisks).Count
                $Count


                Foreach ($i in $Count)

                {
                
                    $SourceDDURI = $VM.StorageProfile.DataDisks[$i].ManagedDisk
                    $DataDiskSnashot = $VM.StorageProfile.DataDisks[$i].Name +"-Backup-" + $Time

                    $VM.Name

                        $diskConfig = New-AzureRmDiskConfig -SourceResourceId $SourceDDURI.Id -Location $VM.Location -CreateOption Copy 

                         New-AzureRmDisk -Disk $diskConfig -DiskName $DataDiskSnashot -ResourceGroupName $VM.ResourceGroupName

                
                }
            }
            <#
            $SourceDD1URI = $VM.StorageProfile.DataDisks[0].ManagedDisk
            $DataDiskSnapshot1 = $VM.StorageProfile.DataDisks[0].Name + "-Backup-" + $Time


                if ($VM.StorageProfile.OsDisk.ManagedDisk -ne $null)

                    {
                        $VM.Name

                        $diskConfig = New-AzureRmDiskConfig -SourceResourceId $SourceOSURI.Id -Location $VM.Location -CreateOption Copy 

                         New-AzureRmDisk -Disk $diskConfig -DiskName $OSDiskSnapshot -ResourceGroupName $VM.ResourceGroupName

                    }

                if ($VM.StorageProfile.DataDisks[0].ManagedDisk -ne $null)

                    {
                        $VM.Name

                        $diskConfig = New-AzureRmDiskConfig -SourceResourceId $SourceDD1URI.Id -Location $VM.Location -CreateOption Copy 

                         New-AzureRmDisk -Disk $diskConfig -DiskName $DataDiskSnapshot1 -ResourceGroupName $VM.ResourceGroupName
                    
                    }
                        
            #>            
                        
            }

}
