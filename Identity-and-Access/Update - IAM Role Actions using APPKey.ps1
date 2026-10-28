
Param 
    (

        [Parameter(Mandatory=$true)]
        [String] $TenantID,

        [Parameter(Mandatory=$true)]
        [String] $IAMName,

        [Parameter(Mandatory=$true)]
        [String] $Add_Remove,

        [Parameter(Mandatory=$true)]
        [String] $AppID,

        [Parameter(Mandatory=$true)]
        [String] $AppKey


    )

$AppUsername = $AppID
$AppSecretKey = $AppKey

$cred = New-Object PSCredential $AppUsername, ($AppSecretKey | ConvertTo-SecureString -AsPlainText -Force)

Connect-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $TenantID 

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


(Get-AzureRmRoleDefinition -Name $IAMName).Actions

$IAMRole = Get-AzureRmRoleDefinition -Name $IAMName

If ($Add_Remove -eq "ADD")

    {

        Foreach ($AIAM in $IAMAccess)

            {
              Write-Output "Adding Actions to IAM Role $IAMName"

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
              Write-Output "Removing Actions from IAM Role $IAMName"
                $RIAM              
                $IAMRole.Actions.Remove($RIAM)
                $IAMRole | Set-AzureRmRoleDefinition

            }

        (Get-AzureRmRoleDefinition -Name $IAMName).Actions
    }