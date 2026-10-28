While($true)
{
 function Test-SQLConnection
{    
    [OutputType([bool])]
    Param
    (
        [Parameter(Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        $ConnectionString
    )
    try
    {
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString;
        $sqlConnection.Open();
        $sqlConnection.Close();

        return $true;
    }
    catch
    {
        $err = $_.Exception
        write-output $err.Message
    }
}

$pro=Test-SQLConnection "Server=<sql-server-host>,1433; Database=<database>; Integrated Security=false;User ID=<SQL_USER>;Password=<PASSWORD>"
$date=Get-Date
$pro|Out-File "c:\usersqllog.txt" -Append
}
