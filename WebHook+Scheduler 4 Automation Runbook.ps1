Select-AzureRmProfile -Path C:\Users\gulab\Desktop\surgul_65.json

#Login-AzureRmAccount
########################################################################################################################################################

# The following variables are passed as parameters for your RunBook through WebHook.

$PVMName = "sowmyademovm112"
$PVMLocation = "SouthIndia"
$PVMSize = "Standard_DS1_V2"
$POSProfile = "Linux"
$PSourceRG = "VHD"
$PSourcestgacc = "testvhdsstg"
$PSourceURI = "https://testvhdsstg.blob.core.windows.net/testvhdsstg/Bigdata-TRNGSetup21-12-2016.vhd"


# The following Variables to fetch the RunBook to which the parameters will be passed.

$Resourcegroup = "Auto-RunBook"
$autoacc = "gulabpasha"
$runbook = "CreateVM-WorkFlow"
$webHookName = $PVMName
$ExDate4WH = "2/10/2017 15:45:45 PM"


$Param = @{ 
            VMName=$PVMName; 
            VMLocation=$PVMLocation; 
            VMSize=$PVMSize;
            OSProfile=$POSProfile; 
            SourceResourceGroup=$PSourceRG; 
            SourceStorageACCName=$PSourcestgacc;
            SourceVHDURI=$PSourceURI
           }


#create Webhook

$webURI = New-AzureRmAutomationWebhook -Name $webHookName -RunbookName $runbook -ResourceGroupName $Resourcegroup `
-AutomationAccountName $autoacc -ExpiryTime $ExDate4WH -IsEnabled $true -Parameters $Param -Force

$webURI.WebhookURI

########################################################################################################################################################


$RG4Job = $Resourcegroup
$jobcollection = $PVMName
$JobName = $PVMName
$location = "Central India"
$JobActionType = "https"
$Method = "POST"
$uri = $webURI.WebhookURI

########################################################################################################
    # Create date object 
    $date1 = New-Object System.DateTime 2017, 2, 10, 10, 00, 0 
    
     
    # Display date and local time zone then show that time in other time zones 
   $Starton = " {0}" -f $date1.ToUniversalTime()
     
########################################################################################################



#To Create New Job Collection.

New-AzureRmSchedulerJobCollection -ResourceGroupName $RG4Job -JobCollectionName $jobcollection -Location $location -MaxJobCount 50

#Create a Scheduler Job.

New-AzureRmSchedulerHttpJob -ResourceGroupName $RG4Job -JobCollectionName $jobcollection -JobName $JobName -Method $Method `
-Uri $uri -StartTime $Starton -JobState Enabled 


$Status = Get-AzureRmSchedulerJob -ResourceGroupName $RG4Job -JobCollectionName $jobcollection -JobName $JobName

$Status
