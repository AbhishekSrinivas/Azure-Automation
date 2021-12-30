

Set-ExecutionPolicy RemoteSigned



$UserCredential = Get-Credential



$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection



Import-PSSession $Session -AllowClobber



Start-ManagedFolderAssistant –Identity sudeep@absace.com



Enable-Mailbox sudeep@absace.com -AutoExpandingArchive


