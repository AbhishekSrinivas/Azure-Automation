Login-AzureRmAccount

$subs = (Get-AzureRmSubscription).Name

$OrphanNIC = @()
$OrphanPIP = @()
$OrphanNSG = @()
$OrphanUMVHD = @()
$OrphanMVHD = @()

foreach ($sub in $subs)
{

    Select-AzureRmSubscription -SubscriptionName "$sub"

    $RG= Get-AzureRmResourceGroup

    $RGS=$RG.ResourceGroupName

    foreach ($R in $RGS)

        {        
            $az_networkinterfaces = Get-AzureRmNetworkInterface -ResourceGroupName $R
            $RemAzNetworkInterface = $az_networkinterfaces |  Where-Object {$_.VirtualMachine -eq $null}
            $OrphanNIC += $RemAzNetworkInterface
            $OrphanNIC.Name


            $az_publicipaddress = Get-AzureRmPublicIpAddress -ResourceGroupName $R
            $RemAzPublicIP = $az_publicipaddress |  Where-Object {$_.IpConfiguration -eq $null}
            $OrphanPIP +=$RemAzPublicIP
            $OrphanPIP.Name

            $az_nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $R
            $RemAzSecurityGroup = $az_nsg |  Select-Object Name, Subnets,Networkinterfaces | Where-Object {$_.subnets.id -eq $null -and $_.networkinterfaces.id -eq $null}
            $OrphanNSG +=$RemAzSecurityGroup
            $OrphanNSG.Name

            $SA = Get-AzureRmStorageAccount -ResourceGroupName $R
            $UMD = $SA | Get-AzureStorageContainer | Get-AzureStorageBlob | Where {$_.Name -like '*.vhd'} 
            $UMVHDS = $UMD | Where {$_.ICloudBlob.Properties.LeaseStatus -eq "Unlocked"} 
            $OrphanUMVHD +=$UMVHDS
            $OrphanUMVHD.Name

            

            $MVHDS = Get-AzureRmDisk -ResourceGroupName $R
            $MVHD = $MVHDS | Where {$_.ManagedBy -eq $null}
            $OrphanMVHD += $MVHD
            $OrphanMVHD.Name

            $VNet = Get-AzureRmVirtualNetwork -ResourceGroupName $R
            $UUVnet=$VNet | Where {$_.Subnets -eq $null}
            $OrphanVNet += $UUVnet
            $OrphanVNet.Name
        
        }

   
} 

#$OrphanNIC
$OrphanNIC.Name


#$OrphanPIP
$OrphanPIP.Name

#$OrphanNSG
$OrphanNSG.Name

#$OrphanUMVHD
$OrphanUMVHD.Name


#$OrphanMVHD
$OrphanMVHD.Name

#$OrphanVNet
$OrphanVNet.Name