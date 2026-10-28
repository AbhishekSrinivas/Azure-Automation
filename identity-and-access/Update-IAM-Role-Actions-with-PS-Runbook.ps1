Param 
    (
        [Parameter(Mandatory=$true)]
        [String] $SubscriptionName,

        [Parameter(Mandatory=$true)]
        [String] $IAMName,


        [Parameter(Mandatory=$true)]
        [String] $IAM_Action

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

Select-AzureRmSubscription -SubscriptionName $SubscriptionName


$IAMAccess=@()
$IAMAccess+=,("Microsoft.Compute/virtualMachines/start/action")
$IAMAccess+=,("Microsoft.Compute/virtualMachines/restart/action")
$IAMAccess+=,("Microsoft.Compute/virtualMachines/poweroff/action")
$IAMAccess+=,("Microsoft.Compute/virtualMachines/deallocate/action")


If ($IAM_Action -eq "Remove")

{
Write-Output "Selecting Subscription to update the IAM Role = $SubscriptionName"

Write-Output "Mentioned below are the current IAM Actions in $IAMName"

Write-Output "Removing VM Start,Stop and Deallocate IAM Actions in $IAMName"

(Get-AzureRmRoleDefinition -Name $IAMName).Actions
        

        $IAMRole = Get-AzureRmRoleDefinition -Name $IAMName

                Foreach ($RIAM in $IAMAccess)

                    {
              
                        $RIAM              
                        $IAMRole.Actions.Remove($RIAM)
                        $IAMRole | Set-AzureRmRoleDefinition

                    }

                (Get-AzureRmRoleDefinition -Name $IAMName).Actions
 }  
 

ElseIf ($IAM_Action -eq "Add")

{

Write-Output "Selecting Subscription to update the IAM Role = $SubscriptionName"

Write-Output "Mentioned below are the current IAM Actions in $IAMName"

(Get-AzureRmRoleDefinition -Name $IAMName).Actions

Write-Output "Adding VM Start,Stop and Deallocate IAM Actions in $IAMName"

        $IAMRole = Get-AzureRmRoleDefinition -Name $IAMName

                Foreach ($AIAM in $IAMAccess)

                    {
              
                        $AIAM              
                        $IAMRole.Actions.Add($AIAM)
                        $IAMRole | Set-AzureRmRoleDefinition

                    }

                (Get-AzureRmRoleDefinition -Name $IAMName).Actions


}
