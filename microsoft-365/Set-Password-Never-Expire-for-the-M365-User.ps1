#Connect-MsolService


#Before the changes
Get-MsolUser -UserPrincipalName user@contoso.com | Select PasswordNeverExpires

#Set the value
Set-MsolUser -UserPrincipalName user@contoso.com -PasswordNeverExpires $true

#after the changes
Get-MsolUser -UserPrincipalName user@contoso.com | Select PasswordNeverExpires
