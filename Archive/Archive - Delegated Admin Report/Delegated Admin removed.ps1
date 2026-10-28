#Import MSOnline module to allow connectivity to Microsoft Office 365
Import-Module MSOnline

#Partner Admin Username to be used to run the Report
$UserName = “user@contoso.onmicrosoft.com"

#Prompt for the password of the Partner Admin Username
$Cred = get-credential -Credential $UserName

#Establish a PS session with Microsoft Office 365
Connect-MsolService -Credential $Cred


#Get Company Tanent ID
$tenantID = (Get-MsolPartnerContract).tenantid | Select -ExpandProperty Guid

$companyname = Get-MsolPartnerContract -All | select @{n="TenantID";e={$_.TenantID.tostring()}} | `
Get-MsolCompanyInformation  -ErrorAction SilentlyContinue | select ObjectId,Displayname,TelephoneNumber | Select -ExpandProperty ObjectId |Select -ExpandProperty Guid

#$tenantID | Export-Csv -path C:\Tenantid.csv
#$companyname | Export-Csv -Path C:\companyname.csv

$Results = Compare-Object -ReferenceObject $Tenantid -DifferenceObject $companyname


ForEach($Result in $Results)  
  {  
  $tenid=$Result|Select -ExpandProperty InputObject

     Get-MsolPartnerInformation -TenantId $tenid | Select -Property PartnerCompanyName

      $i++  
}
