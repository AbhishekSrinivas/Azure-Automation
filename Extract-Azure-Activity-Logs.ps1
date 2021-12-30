﻿
#Login-AzureRmAccount

$results = @()

$Resources

$ActivityLog = "C:\Users\Gulab\Desktop\ActivityLogs.csv"

$StartTime = "2018-07-01T06:00"

$EndTime = "2018-08-23T06:00"

$Subs = Get-AzureRmSubscription



foreach ($Sub in $Subs)

{

Select-AzureRmSubscription -SubscriptionName $Sub.Name


$ACLS = Get-AzureRmLog -StartTime $StartTime -EndTime $EndTime

        Foreach ($ACL in $ACLS)

            {

            $details  = @{ 

                            'SubscriptionName' = $Sub.Name
                            'ResourceGroupName' = $ACL.ResourceGroupName
                            'Caller' = $ACL.Caller
                            'ResourceId' = $ACL.ResourceId
                            'ResourceProviderName' = $ACL.ResourceProviderName
                            'SubmissionTimestamp' = $ACL.SubmissionTimestamp.DateTime
                            'Scope' = $ACL.Authorization.Scope
                            'Action' = $ACL.Authorization.Action

                        }

$results += New-Object PSObject -Property $details

            }

}

$results | Select "SubscriptionName","ResourceGroupName","Caller","ResourceId","ResourceProviderName","SubmissionTimestamp","Scope","Action" | Export-Csv -Path $ActivityLog