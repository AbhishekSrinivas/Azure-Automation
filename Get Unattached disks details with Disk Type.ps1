Login-AzureRmAccount

$Subscriptions = Get-AzureRmSubscription -TenantId "10d6ef10-3ab0-4792-b0e1-717d9c327807"



foreach ($sub in $Subscriptions)
{
    $selsub=Select-AzureRmSubscription -SubscriptionName "$sub"
    $subname = $selsub.Name
    
    # List to store details of unattached managed disks 
    $unattached_managed_disk_object = $null 
    $unattached_managed_disk_object = @() 
 
    # Obtaining list of Managed disks 
    $managed_disk_list = Get-AzureRmDisk 
 
 
 
    ########################################################### 
    # Obtaining list of unattached MANAGED disks 
    ########################################################### 
 
 
    Write-Host " `n`n*************** Obtaining list of unattached MANAGED disks *************** " -ForegroundColor Cyan 
 
    foreach($managed_disk_list_iterator in $managed_disk_list)
    { 
        if($managed_disk_list_iterator.ManagedBy -EQ $null){ 
             
            write-host "Collecting data about an unattached managed disk... `n" -ForegroundColor Gray 
            # Creating a temporary PSObject to store the details of unattached managed disks 
            $unattached_managed_disk_object_temp = new-object PSObject  
            $unattached_managed_disk_object_temp | add-member -membertype NoteProperty -name "ResourceGroupName" -Value $managed_disk_list_iterator.ResourceGroupName 
            $unattached_managed_disk_object_temp | add-member -membertype NoteProperty -name "Name" -Value $managed_disk_list_iterator.Name 
            $unattached_managed_disk_object_temp | add-member -membertype NoteProperty -name "DiskSizeGB" -Value $managed_disk_list_iterator.DiskSizeGB 
            $unattached_managed_disk_object_temp | add-member -membertype NoteProperty -name "Location" -Value $managed_disk_list_iterator.Location
            $unattached_managed_disk_object_temp | add-member -membertype NoteProperty -name "sku" -Value $managed_disk_list_iterator.Sku
            $unattached_managed_disk_object_temp | add-member -membertype NoteProperty -name "Type" -Value ($managed_disk_list_iterator.Sku.Tier)
            
            # Adding the objects to the final list 
            $unattached_managed_disk_object += $unattached_managed_disk_object_temp
            
            $unattached_managed_disk_object
          
           #$unattached_managed_disk_object | Export-Csv -Append -Path "C:\Users\User\OneDrive - G7 CR Technologies India Pvt Ltd\Elastic run\Unattached Disks with Disk Type2.csv" -NoTypeInformation -Force
        } 
       

    } 
    
    Write-Host "Creating CSV file for Unattached Managed Disks ==> unattached_managed_disks.csv" -ForegroundColor Green 
    
    #$unattached_managed_disk_object | Export-Csv  -Path "C:\Users\User\OneDrive - G7 CR Technologies India Pvt Ltd\Elastic run\$subname.csv" -NoTypeInformation -Force 

}

