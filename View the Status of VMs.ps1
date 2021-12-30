Select-AzureRmProfile -Path "C:\Users\gulab\Desktop\Text\Azure Scripts\gmail.json"

$RGs = Get-AzureRMResourceGroup

foreach($RG in $RGs)
{
    $VMs = Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName
    foreach($VM in $VMs)
    {
        $VMDetail = Get-AzureRmVM -ResourceGroupName $RG.ResourceGroupName -Name $VM.Name -Status
        foreach ($VMStatus in $VMDetail.Statuses)
        { 
            #if($VMStatus.Code.CompareTo("PowerState/deallocated") -eq 0)
            if($VMStatus.Code -like "PowerState/*")
            {
                $VMStatusDetail = $VMStatus.DisplayStatus
            }
        }
        write-output $VM.Name $VMStatusDetail
    }
}

