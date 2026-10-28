#Login-AzureRmAccount

$subs = Get-AzureRmSubscription


Foreach ($sub in $subs)

{
    
    Select-AzureRmSubscription -SubscriptionName $sub.Name


    $RGS = Get-AzureRmResourceGroup

    Foreach ($RG in $RGS)

        {
            $RGName=  $RG.ResourceGroupName
             
            $count = (Get-AzureRmResource | where {$_.ResourceGroupName -match $RGName}).Count 
            
            if($count -eq "0")
            
                {
                    Write-Output "The resource group $RGName has $count resources" 
                } 
            
             
        } 

}


