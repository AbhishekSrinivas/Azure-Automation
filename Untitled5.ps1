#Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
$ErrorActionPreference=“silentlycontinue”

 


$Tenant=Get-RdsTenant

 

 

Foreach($TenantN in $Tenant)
{
$TenantName=$TenantN.TenantName

 


Write-Host "Tenant Name $TenantName" -ForegroundColor Green

 

 

$HostPoolName=Get-RdsHostPool -TenantName $TenantName | Select-Object HostPoolName
$HostPools=$HostPoolName.HostPoolName
Foreach($Hostpool in $HostPools)
{
$date=Get-date
$date=Get-date $date -Format dd-MM-yyyy-hh-mm
$Hostpool
$test=Get-RdsUserSession -TenantName $TenantName -HostPoolName $Hostpool|Export-Csv "D:\Swiggy\Usersession-$date.csv"

 

 

Get-RdsSessionHost -TenantName $TenantName -HostPoolName $Hostpool  |Export-Csv "D:\Swiggy\SessionHost-$date.csv"
#$test
#$test.count
}
}

 

 

   <#Get-RdsUserSession  -TenantName $TenantName -HostPoolName $hostpool | `
          where { $_.UserPrincipalName -eq "sanjib.kumar@swiggy.in"}   | Invoke-RdsUserSessionLogoff -NoUserPrompt  -Force

 

 

   Get-RdsUserSession  -TenantName $TenantName -HostPoolName $hostpool | `
          where { $_.UserPrincipalName -eq "ishani.1_kt@external.swiggy.in"}  #>

 


#Get-RdsDiagnosticActivities  -TenantName $TenantName -StartTime "29/4/2020 3:45:00 PM" -EndTime "30/4/20203:50:00 PM" -Detailed

 