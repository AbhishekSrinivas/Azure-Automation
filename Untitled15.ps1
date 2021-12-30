
#Login-AzureRmAccount
 
 
Select-AzureRmSubscription -Subscription "c2327cd8-9874-432f-9450-d308f1c583a9"
$ErrorActionPreference="SilentlyContinue"
 
$csv=Import-csv -Path "D:\walmartvmlist.csv"
 
#$vms= Get-AzureRmVM | ?  {$_.Name -eq "VDI-COMC02-62" -or $_.Name -eq "VDI-COMC02-63" -or $_.Name -eq "VDI-COMC02-64" } |Select ResourceGroupName,Name,Location,Id
 
Foreach($myvm in $csv)
{
$myvmname=$myvm.Name
 
$vm= Get-AzureRmVM | ?  {$_.Name -eq $myvmname} |Select ResourceGroupName,Name,Location,Id
 
$rgName=$vm.ResourceGroupName
$vmName=$vm.Name
$Location=$vm.Location
$vmResourceId=$vm.Id
$url="rdbroker.wvd.microsoft.com"
$portnum="443"
 
$getextension=get-AzureRmVMExtension -ResourceGroupName $rgName -VMName $vmName -Name "AzureNetworkWatcherExtension"
if($getextension  -eq $null)
 
{
#Install Network Watcher Agent
Set-AzureRmVMExtension `
  -ResourceGroupName $rgName `
  -Location $Location `
  -VMName $vmName `
  -Name "networkWatcherAgent" `
  -Publisher "Microsoft.Azure.NetworkWatcher" `
  -Type "NetworkWatcherAgentWindows" `
  -TypeHandlerVersion "1.4"
}
 
 
 
$getextensioncheck=get-AzureRmVMExtension -ResourceGroupName $rgName -VMName $vmName -Name "AzureNetworkWatcherExtension"
 
 
    if($getextensioncheck -ne $null)
    {
 
 
    do {
      try {
 
     $stoploop=$false
    [int] $Retrycount="0"
 
    # Get All Network Watcher
    #$AllNetworkWatcher=Get-AzureRmNetworkWatcher| Select Name,Location
    #$AllNetworkWatcher
 
                if($Location -eq "centralus")
                {
                $networkwatcherName="NetworkWatcher_centralus"
                $rg="NetworkWatcherRG"
 
                #get south central US Network Watcher Context 
                $getcusnetwatch=Get-AzureRmNetworkWatcher -Name $networkwatcherName -ResourceGroupName $rg
 
                # Network Watcher connection Monitor
                $monitorName=$vmName
 
                $vmResourceID=$vmResourceId
                $destinationAddress=$url
                $port=$portnum
 
                     $ifexist=Get-AzureRmNetworkWatcherConnectionMonitor -NetworkWatcherName $networkwatcherName -ResourceGroupName $rg -Name $monitorName
 
                     if($ifexist.ProvisioningState -ne "Succeeded")
                     {
 
 
                    New-AzureRmNetworkWatcherConnectionMonitor -NetworkWatcher $getcusnetwatch -Name $monitorName -SourceResourceId $vmResourceID  `
                      -DestinationAddress $destinationAddress  -DestinationPort $port   -Force
 
                      }
        #Get-AzureRmNetworkWatcherConnectionMonitor -NetworkWatcherName "NetworkWatcher_southcentralus" -ResourceGroupName NetworkWatcherRG -Name V-Walmart1-0
                  }
                  if($Location -eq "southcentralus")
                  {
                    $networkwatcherName="NetworkWatcher_southcentralus"
                    $rg="NetworkWatcherRG"
 
                    #get south central US Network Watcher Context 
                    $getsusnetwatch=Get-AzureRmNetworkWatcher -Name $networkwatcherName -ResourceGroupName $rg
 
                    # Network Watcher connection Monitor
                    $monitorName=$vmName
 
                    $vmResourceID=$vmResourceId
                    $destinationAddress=$url
                    $port=$portnum
       
 
                     $ifexist=Get-AzureRmNetworkWatcherConnectionMonitor -NetworkWatcherName $networkwatcherName -ResourceGroupName $rg -Name $monitorName
 
                     if($ifexist.ProvisioningState -ne "Succeeded")
                     {
 
 
                    New-AzureRmNetworkWatcherConnectionMonitor -NetworkWatcher $getsusnetwatch -Name $monitorName -SourceResourceId $vmResourceID  `
                      -DestinationAddress $destinationAddress  -DestinationPort $port   -Force
                      }
                   }
            Write-Host "Job done for $vmName" -ForegroundColor Green
            }
            catch {
            if ($Retrycount -gt 3)
            {
            Write-Host "Could not complete after 3 tries"
            $stoploop =$true
            }
            else
            {
            Write-Host "Could not complete,retrying in 5 secs"
            Start-sleep -Seconds 5
            $Retrycount = $Retrycount + 1
            }
     
           }
 
      }
          while($stoploop -eq $true)
    }
 
  }
 
 
