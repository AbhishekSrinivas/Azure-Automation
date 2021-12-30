workflow startORstop
{
   Param
    (

        [Parameter(Mandatory=$true)]
        [String]
        $ResourceGroupName = '*',

        [Parameter(Mandatory=$true)]
        [Boolean]
        $Shutdown
    )
    $connectionName = "AzureRunAsConnection"
    try
    {
    
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }
    catch 
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
        }
    }

    If ($ResourceGroupName -eq '*')
    {
        $vms = Get-AzureRmVM
        Foreach -Parallel ( $vm in $vms ) 
        {
                        
            if ( $Shutdown ) 
            {
                Write-Output "Stopping $($vm.Name)";              
                Stop-AzureRmVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force;
            }

            else 
            {
                Write-Output "Starting $($vm.Name)";                
                Start-AzureRmVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName;
            }
        }

    }
    
    Else
    {
        $vms = Get-AzureRmVM -ResourceGroupName $ResourceGroupName;   

        Foreach -Parallel ( $vm in $vms ) 
        {                        
            if ( $Shutdown ) 
            {
                Write-Output "Stopping $($vm.Name)";              
                Stop-AzureRmVm -Name $vm.Name -ResourceGroupName $ResourceGroupName -Force;
            }

            else 
            {
                Write-Output "Starting $($vm.Name)";                
                Start-AzureRmVm -Name $vm.Name -ResourceGroupName $ResourceGroupName;
            }
        }
    }

}