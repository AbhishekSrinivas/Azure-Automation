Login-AzureRmAccount

$Subscriptions = Get-AzureRmSubscription

$IAMName = "Gulab"

#Adding RBAC Role Actions **************************************
$IAMAccess=@()
$IAMAccess+=,("Microsoft.Resources/subscriptions/resourceGroups/read")
$IAMAccess+=,("Microsoft.Compute/locations/*")
$IAMAccess+=,("Microsoft.Compute/virtualMachines/read")
$IAMAccess+=,("Microsoft.Compute/virtualMachines/start/action")
$IAMAccess+=,("Microsoft.Compute/virtualMachines/restart/action")
$IAMAccess+=,("Microsoft.Compute/virtualMachines/poweroff/action")
$IAMAccess+=,("Microsoft.Compute/virtualMachines/deallocate/action")
$IAMAccess+=,("Microsoft.Authorization/*/read")
$IAMAccess+=,("Microsoft.Network/networkInterfaces/read")
$IAMAccess+=,("Microsoft.Network/networkInterfaces/*")
$IAMAccess+=,("Microsoft.Network/*")
$IAMAccess+=,("Microsoft.Network/*/read")


#Removing RBAC Role Actions **************************************

$IAMNoAccess=@()
$IAMNoAccess+=,("Microsoft.Resources/subscriptions/resourceGroups/read")
$IAMNoAccess+=,("Microsoft.Compute/locations/*")
$IAMNoAccess+=,("Microsoft.Compute/virtualMachines/read")
$IAMNoAccess+=,("Microsoft.Compute/virtualMachines/start/action")
$IAMNoAccess+=,("Microsoft.Compute/virtualMachines/restart/action")
$IAMNoAccess+=,("Microsoft.Compute/virtualMachines/poweroff/action")
$IAMNoAccess+=,("Microsoft.Compute/virtualMachines/deallocate/action")
$IAMNoAccess+=,("Microsoft.Authorization/*/read")
$IAMNoAccess+=,("Microsoft.Network/networkInterfaces/read")
$IAMNoAccess+=,("Microsoft.Network/networkInterfaces/*")
$IAMNoAccess+=,("Microsoft.Network/*")
$IAMNoAccess+=,("Microsoft.Network/*/read")


Foreach ($Subscription in $Subscriptions)

{

$SubscriptionName = $Subscription.Name

Select-AzureRmSubscription -SubscriptionName $SubscriptionName

Write-Output "Selecting Subscription to update the IAM Role = $SubscriptionName"

        (Get-AzureRmRoleDefinition -Name $IAMName).Actions

        $IAMRole = Get-AzureRmRoleDefinition -Name $IAMName

        If ($Add_Remove -eq "ADD")

            {

                Foreach ($AIAM in $IAMAccess)

                    {
              
                        $AIAM              
                        $IAMRole.Actions.Add($AIAM)
                        $IAMRole | Set-AzureRmRoleDefinition

                    }

                (Get-AzureRmRoleDefinition -Name $IAMName).Actions

            }


        Elseif ($Add_Remove -eq "Remove")

            {

                Foreach ($RIAM in $IAMNoAccess)

                    {
              
                        $RIAM              
                        $IAMRole.Actions.Remove($RIAM)
                        $IAMRole | Set-AzureRmRoleDefinition

                    }

                (Get-AzureRmRoleDefinition -Name $IAMName).Actions
            }

}