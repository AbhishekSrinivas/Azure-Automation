

Select-AzureRmSubscription -SubscriptionId "e5f8f6c2-4e05-49c3-8b3b-6db6b5bc8584"

$results = @()
$File = "C:\Users\Gulab\Desktop\Desktop\Abhishek.csv"

$STGS = Get-AzureRmStorageAccount

Foreach ($STG in $STGS)

{


    $StorageAccount = Get-AzureRmStorageAccount -Name $STG.StorageAccountName -ResourceGroupName $STG.ResourceGroupName

       $STGRGName = $StorageAccount.ResourceGroupName
       $STGName = $StorageAccount.StorageAccountName
       

    Foreach ($stgac in $StorageAccount)

    {
       $CNTS = Get-AzureRmStorageContainer -StorageAccountName $stgac.StorageAccountName -ResourceGroupName $stgac.ResourceGroupName

       Foreach ($CNT in $CNTS)

       {
            $ContainerName = $CNT.Name

            $listOfBLobs = Get-AzureStorageBlob -Container $CNT.Name -Context $stgac.Context
        
            $BlobName = $listOfBLobs.Name

            $length = 0 
       
       $details  = @{ 
                        'StorageAccountResourceGroupName' = $STGRGName
                        'StorageAccountName' = $STGName
                        'ContainerName'= $ContainerName
                        'BlobName' = $BlobName
                    }

            $results += New-Object PSObject -Property $details

       }
       

    }

}

$results | Select "StorageAccountResourceGroupName","StorageAccountName","ContainerName","BlobName" | Export-Csv -Path $file
