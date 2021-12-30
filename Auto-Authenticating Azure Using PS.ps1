
#First login to Azure

Login-AzureRmAccount

#or

Add-AzureRmAccount 

#To Save the Auto Authentication JSON File.

$path = "C:\users\gulab\Desktop\AzureSubscription.json"
Save-AzureRmContext -Path $path -Force


#Once that’s done, from then on you can use the Import-AzureRmContext to automate the login.

$path = "C:\users\gulab\Desktop\AzureSubscription.json"
Import-AzureRmContext -Path $path


#Be warned, this does present a security issue. If someone were to steal your context file, they could then login as you. 
#You need to be sure your context file is stored in a safe location no one can get to.

Select-AzureRmSubscription -SubscriptionName "G7CRM4L008"