Using module PartnerCenterModule

$file = "C:\Users\user\Desktop\All_Subs_RoleS.xlsx"

$results = @()

$Resources

$clientSecret = '<STORAGE_ACCOUNT_KEY>'

$clientSecretSecure = $clientSecret | ConvertTo-SecureString -AsPlainText -Force


Add-PCAuthentication -cspappID '<GUID>' -cspDomain 'contoso.onmicrosoft.com' -cspClientSecret $clientSecretSecure

$Customers = Get-PCCustomer
#$Customers.companyprofile.companyName

$adminUsername = 'user@contoso.onmicrosoft.com'
$adminPassword = '<PASSWORD>'

$cred = New-Object PSCredential $adminUsername, ($adminPassword | ConvertTo-SecureString -AsPlainText -Force)

$Customer.companyprofile.companyName
$CustDomain = $Customer.companyProfile.domain



Foreach ($Customer in $Customers)

{

#$Customer.companyProfile.companyName

Connect-AzureRmAccount -TenantId $Customer.companyProfile.tenantId -Credential $cred


$sub = Get-AzureRmSubscription -TenantId $Customer.companyProfile.tenantId

        foreach($subs in $sub)
       
        {

        $ErrorActionPreference = "silentlycontinue"

            $subname = Select-AzureRmSubscription -SubscriptionID $subs.Id
            $subname.Subscription.Name
            $subname.Subscription.Id
            $Roles = Get-AzureRmRoleAssignment

                Foreach ($Role in $Roles)

                    {

                         $ErrorActionPreference = "silentlycontinue"

                                    $Customer.companyProfile.companyName
                                    $subname.Subscription.Name
                                    $Role.DisplayName 
                                    $Role.SignInName 
                                    $Role.RoleDefinitionName

                    <#$details  = @{ 

                                    'CustomerName' = $Customer.companyProfile.companyName
                                    'SubscriptionName' = $subname.Subscription.Name
                                    'DisplayName' = $Role.DisplayName 
                                    'SignInName' = $Role.SignInName 
                                    'RoleDefinitionName' = $Role.RoleDefinitionName
                
                               }#>

                            #$results += New-Object PSObject -Property $details
                    }


    } 
}

#$results | Select "CustomerName","SubscriptionName","DisplayName","SignInName","RoleDefinitionName" | Export-Excel -Path $file



