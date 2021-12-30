workflow Parallel-Create-NetworkResources
{

        Param
            (
                [Parameter(Mandatory=$true)]
                [String] $SharedResourcesRGName,

                [Parameter(Mandatory=$true)]
                [String] $SharedResourcesName,

                [Parameter(Mandatory=$true)]
                [String] $Location,

                [Parameter(Mandatory=$true)]
                [String] $NoOfResources,

                [Parameter(Mandatory=$true)]
                [String] $ADDPrefix
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

"Creating Resource Group for Shared Network Resources"

New-AzureRmResourceGroup -Name $SharedResourcesRGName -Location $Location -Force

foreach -parallel ($i in 1..$NoOfResources)

    {
        InlineScript
                    {

$i = $Using:i 
$VMName = $Using:SharedResourcesName + $i.ToString("000")
$DNSName = "$VMName".ToLower()


"Creating Virtual Network ad Subnet Config"

        $subnet = New-AzureRmVirtualNetworkSubnetConfig -Name "$VMName-Subnet" -AddressPrefix $Using:ADDPrefix

        $vnet = New-AzureRmVirtualNetwork -Name "$VMName-VNet" -ResourceGroupName $Using:SharedResourcesRGName `
        -Location $Using:Location -AddressPrefix $Using:ADDPrefix -Subnet $subnet

        
"Associating Virtual Network with Subnet"

        Set-AzureRmVirtualNetworkSubnetConfig -Name $subnet.Name -VirtualNetwork $vnet -AddressPrefix $Using:ADDPrefix
            
        Set-AzureRmVirtualNetwork -VirtualNetwork $vnet        

"Creating Public IP with DNS Name"
        
        $pip = New-AzureRmPublicIpAddress -Name "$VMName-PIP" -ResourceGroupName $Using:SharedResourcesRGName -Location $Using:Location `
                -AllocationMethod Dynamic -IpAddressVersion IPv4 -DomainNameLabel $DNSName -Force

"Creating Network Interface Card"

        $nic = New-AzureRmNetworkInterface -Name "$VMName-NIC" -ResourceGroupName $Using:SharedResourcesRGName -Location $Using:Location `
                -SubnetId $vnet.Subnets[0].id -PublicIpAddressId $pip.Id -Force
                
                    } #InlineScript Closes Here.
    } #Foreach -Parallel Closes Here.
} #Workflow Closes here.