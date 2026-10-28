$resourceGroupName="StorageRG"    
$storageAccName="newteststorage1"    
  
## Connect to Azure Account    
Login-AzureRmAccount
  
## Function to get all the containers    
Function GetAllStorageContainer    
{    
    Write-Host -ForegroundColor Green "Retrieving storage container.."        
    ## Get the storage account from which container has to be retrieved    
    $storageAcc=Get-AzureRMStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccName        
    ## Get the storage account context    
    $ctx=$storageAcc.Context    
    ## List all the containers    
    $containers=Get-AzureRMStorageContainer  -Context $ctx     
    foreach($container in $containers)    
    {    
        write-host -ForegroundColor Yellow $container.Name    
    }    
}     
    
GetAllStorageContainer 