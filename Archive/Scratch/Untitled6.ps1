Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"

#get the machines details
Get-RdsSessionHost -TenantName ContosoWFH -HostPoolName VDI-Contoso-P1 | Export-Csv "D:\Contoso\Issue\swigyvms.csv"

Get-RdsUserSession -TenantName ContosoWFH -HostPoolName VDI-Contoso-P1 | Export-Csv "D:\Contoso\Issue\swigyuserslis.csv"