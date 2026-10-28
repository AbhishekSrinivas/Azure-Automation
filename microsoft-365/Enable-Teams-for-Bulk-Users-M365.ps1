Connect-MsolService

$users = Import-Csv -Path "D:\Testing.csv"
#$skus = Get-MsolAccountSku |? {$_.AccountSkuId -eq "reseller-account:STANDARDWOFFPACK_FACULTY"} | Select -ExpandProperty ServiceStatus
    
foreach ($user in $users ) 
{


    $userUPN=$user.UserPrincipalName
    
    $userUPN

    $planList= @("KAIZALA_O365_P2","WHITEBOARD_PLAN1","BPOS_S_TODO_2","SCHOOL_DATA_SYNC_P1","Deskless","FLOW_O365_P2","POWERAPPS_O365_P2","RMS_S_ENTERPRISE","OFFICE_FORMS_PLAN_2","PROJECTWORKMANAGEMENT","SWAY","INTUNE_O365","YAMMER_EDU","MCOSTANDARD")

    $licenseOptions=New-MsolLicenseOptions -AccountSkuId "reseller-account:STANDARDWOFFPACK_STUDENT" -DisabledPlans $planList
    

    $user=Get-MsolUser -UserPrincipalName $userUPN
    $usageLocation=$user.Usagelocation
    Set-MsolUserLicense -UserPrincipalName $userUpn -AddLicenses "reseller-account:STANDARDWOFFPACK_STUDENT" -ErrorAction SilentlyContinue
    Sleep -Seconds 5
    Set-MsolUserLicense -UserPrincipalName $userUpn -LicenseOptions $licenseOptions -ErrorAction SilentlyContinue
    Set-MsolUser -UserPrincipalName $userUpn -UsageLocation $usageLocation

} 
 