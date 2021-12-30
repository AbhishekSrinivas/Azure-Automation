Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"

#get the machines details
Get-RdsSessionHost -TenantName SwiggyWFH -HostPoolName VDI-SWIGGY-P1 | Export-Csv "D:\Swiggy\Issue\swigyvms.csv"

Get-RdsUserSession -TenantName SwiggyWFH -HostPoolName VDI-SWIGGY-P1 | Export-Csv "D:\Swiggy\Issue\swigyuserslis.csv"