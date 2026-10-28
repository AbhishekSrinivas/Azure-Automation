Param
    (
        [Parameter(Mandatory=$true)]
        [String] $SourceRGName,

        [Parameter(Mandatory=$true)]
        [String] $SourceSTGAccName,

        [Parameter(Mandatory=$true)]
        [String] $SourceCNTName1,

        [Parameter(Mandatory=$true)]
        [String] $SourceCNTName2,
        
        [Parameter(Mandatory=$true)]
        [String] $DestinationRGName,

        [Parameter(Mandatory=$true)]
        [String] $DestinationSTGAccName
    )

"#******************************* Login to Azure Run As Connection ********************************************#"
$connectionName = "AzureRunAsConnection"
    
Try
    {
# Get the connection "AzureRunAsConnection"
        
            $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

"Logging in to Azure..."

            Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }

Catch 
    {
        if (!$servicePrincipalConnection)
            {
                $ErrorMessage = "Connection $connectionName not found."
                throw $ErrorMessage
            } 
        else
            {
                Write-Error -Message $_.Exception
                throw $_.Exception
                $ErrorMessage = $_.Exception

            }
    }   
"#******************************* Successfully Logged in to Azure Run As Connection ********************************#"


### Source Storage Account Key ###

$srcStorageKey = (Get-AzureRmStorageAccountkey -ResourceGroupName $SourceRGName -Name $SourceSTGAccName).Value[0]

### Target Storage Account key###
$destStorageKey = (Get-AzureRmStorageAccountkey -ResourceGroupName $DestinationRGName -Name $DestinationSTGAccName).Value[0]

### Create the source storage account context ### 
$srcContext = New-AzureStorageContext   -StorageAccountName $SourceSTGAccName -StorageAccountKey $srcStorageKey 
  
### Create the destination storage account context ### 
$destContext = New-AzureStorageContext  -StorageAccountName $DestinationSTGAccName -StorageAccountKey $destStorageKey 


$CDate = Get-Date -Format "dd-mm-yyyy"
$CDate = $CDate


### Create the first container on the destination ### 
New-AzureStorageContainer -Name "$SourceCNTName1$CDate" -Context $destContext

#Get a reference to blobs in the source container.
$blob1 = Get-AzureStorageBlob -Container $SourceCNTName1 -Context $srcContext

Foreach ($blob1 in $blob1.Name)
{
#Copy blobs from one container to another.
$blob1 = Start-AzureStorageBlobCopy -DestContainer $SourceCNTName1$CDate -DestContext $destContext -SrcBlob $blob1 -SrcContainer $SourceCNTName1 -Context $srcContext
}

### Retrieve the current status of the blob copy operation ###
$status = $blob1 | Get-AzureStorageBlobCopyState
  
### Print out status ### 
$status
  
### Loop until complete ###                                    
While($status.Status -eq "Pending"){
  $status = $blob1 | Get-AzureStorageBlobCopyState
  Start-Sleep 30
  ### Print out status ###
  $status
}


### Create the second container on the destination ### 
New-AzureStorageContainer -Name "$SourceCNTName2$CDate" -Context $destContext

#Get a reference to blobs in the source container.
$blob2 = Get-AzureStorageBlob -Container $SourceCNTName2 -Context $srcContext

Foreach ($blob2 in $blob2.Name)
{
#Copy blobs from one container to another.
$blob2 = Start-AzureStorageBlobCopy -DestContainer $SourceCNTName2$CDate -DestContext $destContext -SrcBlob $blob2 -SrcContainer $SourceCNTName2 -Context $srcContext
}

### Retrieve the current status of the blob copy operation ###
$status = $blob2 | Get-AzureStorageBlobCopyState
  
### Print out status ### 
$status
  
### Loop until complete ###                                    
While($status.Status -eq "Pending"){
  $status = $blob2 | Get-AzureStorageBlobCopyState
  Start-Sleep 30
  ### Print out status ###
  $status
}