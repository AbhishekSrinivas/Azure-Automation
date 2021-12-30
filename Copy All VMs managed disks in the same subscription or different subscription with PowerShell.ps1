


# This script will get ALL VMs in a subscription and then migrate the disks if the VM has managed disks
Login-AzureRmAccount

#set global variables
$sourceSubscriptionId='ccc8a675-5108-4bb4-9502-7faafbbc9847'
select-azurermsubscription -subscriptionid $sourceSubscriptionId
$vms = get-azurermvm
$targetSubscriptionId='1b2edbb4-6b89-4175-b53a-4fca06416c18'


#looping logic for each of the VMs that have managed disks
foreach ($vm in $vms) {
select-azurermsubscription -subscriptionid $sourceSubscriptionId

$vmrg = get-azurermresourcegroup -name $vm.ResourceGroupName
$vmname = $vm.name

Write-Host = "Working with: " $vmname " in " $vmrg -foregroundcolor Green 
Write-Host ""

#This command will only target managed disks because unmanaged use the storage account locations rather than the /disks provider URIs

if (Get-AzureRmDisk | ? {$_.OwnerId -like "/subscriptions/"+$sourceSubscriptionId +"/resourceGroups/"+$vmrg.resourcegroupname+"/providers/Microsoft.Compute/virtualMachines/"+$vm.name})
{
#Sanity Check
#Read-host "Look correct? If not, CTRL-C to Break"
$manageddisk =  Get-AzureRmDisk | ? {$_.OwnerId -like "/subscriptions/"+$sourceSubscriptionId +"/resourceGroups/"+$vmrg.resourcegroupname+"/providers/Microsoft.Compute/virtualMachines/"+$vm.name}
Select-AzureRmSubscription -SubscriptionId $targetSubscriptionId
#check to see if RG exists in the new CSP/Subscription 

Get-AzureRmResourceGroup -Name $vmrg.resourcegroupname -ev notPresent -ea 0
write-host "Checking to see if"$vmrg.resourcegroupname"exists in subscriptionid"$targetSubscriptionId -foregroundcolor Cyan
Write-Host ""
if ($notPresent)
{
    new-azurermresourcegroup -name $vmrg.resourcegroupname -location $vmrg.location
    "Resource Group " + $vmrg.resourcegroupname + " has been created"
    } else {"Resource Group " + $vmrg.resourcegroupname +  " already exists"}
    # Move the disks after all checks are done
    foreach ($disk in $managedDisk){
        $managedDiskName = $disk.Name
        $targetResourceGroupName = $vmrg.resourcegroupname

        $diskConfig = New-AzureRmDiskConfig -SourceResourceId $disk.Id -Location $disk.Location -CreateOption Copy 

        New-AzureRmDisk -Disk $diskConfig -DiskName $Disk.Name -ResourceGroupName $targetResourceGroupName}
}
} 


