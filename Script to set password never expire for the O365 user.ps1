#Connect-MsolService


#Before the changes
Get-MsolUser -UserPrincipalName support@princetonhive.com | Select PasswordNeverExpires

#Set the value
Set-MsolUser -UserPrincipalName support@princetonhive.com -PasswordNeverExpires $true

#after the changes
Get-MsolUser -UserPrincipalName support@princetonhive.com | Select PasswordNeverExpires
