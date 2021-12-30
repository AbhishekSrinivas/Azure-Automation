#connect the library MySql.Data.dll
Add-Type –Path 'C:\Program Files (x86)\MySQL\MySQL Connector Net 6.10.6\Assemblies\v4.5.2\MySql.Data.dll'

# database connection string, server — server name, uid - mysql user name, pwd- password, database — name of the database on the server
$Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString='server=52.48.184.104;uid=ss_admin;pwd=Zo5zhdt57w@g7;database=g7crdb'}
$Connection.Open()
$sql = New-Object MySql.Data.MySqlClient.MySqlCommand
$sql.Connection = $Connection

$UserList= Import-Csv -Path "C:\Users\Gulab\Desktop\Book3.csv"

#$UserList.Username
#$UserList.EmailID

ForEach($user in $UserList)
{
$uname=$user.Username;
$uemail=$user.EmailID;

$uname
$uemail

#write the information about each use to the database table
$sql.CommandText = "INSERT INTO shankar (Username,EmailID) VALUES ('$uname','$uemail')"
$sql.ExecuteNonQuery()
}
$Reader.Close()
$Connection.Close()

