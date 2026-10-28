#Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionID ""

$RGName = "win2012-rg"
$VMName = "win2012r2"

$VaultName = "TestASR"
$OSDisk = "win2012r2_OsDisk_1_514e145ef17846e29b293d846b61d5f6"
$DataDisk = "disk1"
$CacheSTG = "win2012rgdiag"


$vm = Get-AzureRmVM -ResourceGroupName $RGName -Name $VMName

$ASRVault = Get-AzureRmRecoveryServicesVault -ResourceGroupName "TestASR" -Name $VaultName

Set-ASRVaultSettings -Vault $ASRVault
Set-AzureRmRecoveryServicesAsrVaultContext -Vault $ASRVault

$TempASRJobPri = New-ASRFabric -Azure -Location 'SouthEast Asia' -Name "A2A-SoutheastAsia"
$PrimaryFabric = Get-AsrFabric -Name "A2A-SoutheastAsia"


$TempASRJobRec = New-ASRFabric -Azure -Location 'East Asia'  -Name "A2A-EastAsia"
$RecoveryFabric = Get-AsrFabric -Name "A2A-EastAsia"


$TempASRPROPrime = New-AzureRMRecoveryServicesAsrProtectionContainer -InputObject $PrimaryFabric -Name "A2ASouthEastAsiaProtectionContainer"
$PrimaryProtContainer = Get-ASRProtectionContainer -Fabric $PrimaryFabric -Name "A2ASouthEastAsiaProtectionContainer"


$TempASRJobProRec = New-AzureRMRecoveryServicesAsrProtectionContainer -InputObject $RecoveryFabric -Name "A2AEastAsiaProtectionContainer"
$RecoveryProtContainer = Get-ASRProtectionContainer -Fabric $RecoveryFabric -Name "A2AEastAsiaProtectionContainer"


$TempASRJobPolicy = New-ASRPolicy -AzureToAzure -Name "A2APolicy" -RecoveryPointRetentionInHours 24 -ApplicationConsistentSnapshotFrequencyInHours 4
$ReplicationPolicy = Get-ASRPolicy -Name "A2APolicy"


$TempASRJobMapping = New-ASRProtectionContainerMapping -Name "A2APrimaryToRecovery" -Policy $ReplicationPolicy -PrimaryProtectionContainer $PrimaryProtContainer `
                    -RecoveryProtectionContainer $RecoveryProtContainer
$southEastToEastAsiaPCMapping = Get-ASRProtectionContainerMapping -ProtectionContainer $PrimaryProtContainer -Name "A2APrimaryToRecovery"

$TempASRFailback = New-ASRProtectionContainerMapping -Name "A2ARecoveryToPrimary" -Policy $ReplicationPolicy -PrimaryProtectionContainer $RecoveryProtContainer `
                    -RecoveryProtectionContainer $PrimaryProtContainer


$EastAsiaRecoveryVnet = New-AzureRMVirtualNetwork -Name "ASR-VNet" -ResourceGroupName "TestASR" -Location 'East Asia' -AddressPrefix "11.0.0.0/16"
Add-AzureRMVirtualNetworkSubnetConfig -Name "ASR-SNet" -VirtualNetwork $EastAsiaRecoveryVnet -AddressPrefix "11.0.1.0/24" | Set-AzureRMVirtualNetwork

$EastAsiaRecoveryNetwork = $EastAsiaRecoveryVnet.Id

$SplitNicArmId = $VM.NetworkProfile.NetworkInterfaces[0].Id.split("/")
$NICRG = $SplitNicArmId[4]
$NICname = $SplitNicArmId[-1]
$NIC = Get-AzureRMNetworkInterface -ResourceGroupName $NICRG -Name $NICname
$PrimarySubnet = $NIC.IpConfigurations[0].Subnet
$SouthAsiaPrimaryNetwork = (Split-Path(Split-Path($PrimarySubnet.Id))).Replace("\","/")


$TempASRNetworkMap = New-ASRNetworkMapping -AzureToAzure -Name "A2ASouthTOEastAsiaNWMapping" -PrimaryFabric $PrimaryFabric `
                    -PrimaryAzureNetworkId $SouthAsiaPrimaryNetwork -RecoveryFabric $RecoveryFabric -RecoveryAzureNetworkId $EastAsiaRecoveryNetwork


$cachestorage = Get-AzureRmStorageAccount -ResourceGroupName $RGName -Name $CacheSTG


$OSDid = $vm.StorageProfile.OsDisk.ManagedDisk.Id
$DDid = $vm.StorageProfile.DataDisks[0].ManagedDisk.id

$TargetRG = "a2ademorecoveryrg"
$DestLocation = "East Asia"

$RecoveryRG = Get-AzureRmResourceGroup -Name $TargetRG -Location $DestLocation

$RecoveryOSDiskAccountType = $vm.StorageProfile.OsDisk.ManagedDisk.StorageAccountType
$RecoveryReplicaDiskAccountType =  $vm.StorageProfile.OsDisk.ManagedDisk.StorageAccountType

$RecoveryReplicaDiskAccountType =  $vm.StorageProfile.DataDisks[0].StorageAccountType
$RecoveryTargetDiskAccountType = $vm.StorageProfile.DataDisks[0].StorageAccountType

$OSDiskReplicationConfig = New-AzureRmRecoveryServicesAsrAzureToAzureDiskReplicationConfig -LogStorageAccountId $cachestorage.Id -DiskId $OSDid -RecoveryResourceGroupId $RecoveryRG.ResourceId `
                            -RecoveryReplicaDiskAccountType Standard_LRS -RecoveryTargetDiskAccountType Standard_LRS -ManagedDisk

$DataDiskReplicationConfig = New-AzureRmRecoveryServicesAsrAzureToAzureDiskReplicationConfig -LogStorageAccountId $cachestorage.Id -DiskId $DDid -RecoveryResourceGroupId $RecoveryRG.ResourceId `
                            -RecoveryReplicaDiskAccountType Standard_LRS -RecoveryTargetDiskAccountType Standard_LRS -ManagedDisk



#Create a list of disk replication configuration objects for the disks of the virtual machine that are to be replicated.
$diskconfigs = @()
$diskconfigs += $OSDiskReplicationConfig, $DataDiskReplicationConfig

$TempASR = New-ASRReplicationProtectedItem -AzureToAzure -AzureVmId $Vm.Id -Name (New-Guid).Guid -AzureToAzureDiskReplicationConfiguration $diskconfigs `
            -RecoveryResourceGroupId $RecoveryRG.ResourceId -ProtectionContainerMapping $southEastToEastAsiaPCMapping










