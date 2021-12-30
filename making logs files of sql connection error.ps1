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

$pro=Test-SQLConnection "Server=40.122.72.122,1433; Database=check; Integrated Security=false;User ID=sqladmin;Password=P@ssword@sql12"
$date=Get-Date
$pro|Out-File "c:\proloysqllog.txt" -Append
}
