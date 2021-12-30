#List all counters
#$ListSet = Get-Counter -ListSet *
#$ListSet.Counter 



#CPU
$report=@()

$info =""|Select  CpuTimeStamp,CpuAverageValue,CpuMinValue,CpuMaxValue,MemUsedTimeStamp,MemUsedAvg,MemUsedMin,`
MemUsedMax,AvailMemTimeStamp,AvailMemAvg,AvailMemMin,AvailMemMax,DiskWriteTimestamp,DiskWriteAvg,DiskWriteMin,DiskWriteMax,`
DiskReadTimestamp,DiskReadAvg,DiskReadMin,DiskReadMax,FreeSpaceTimestamp,FreespaceAvg,FreespaceMin,FreespaceMax

Write-Host "CPU" -ForegroundColor Green 
$cpu=Get-Counter -Counter "\Processor(_Total)\% Processor Time"  -SampleInterval 2 -MaxSamples 5
$cputimestamp=$cpu.Timestamp[0]
$info.CpuTimeStamp=$cputimestamp

$cpuvalue=$cpu.Countersamples.cookedvalue

Write-Host "Time Generated $cputimestamp"

$average=($cpuvalue | Measure-Object -Average).average
$info.CpuAverageValue=$average
Write-Host "Average $average" -ForegroundColor Yellow

$min=($cpuvalue | Measure-Object -Minimum).Minimum
$info.CpuMinValue=$min
Write-Host "Minimum $min" -ForegroundColor Yellow

$max=($cpuvalue | Measure-Object -Maximum ).Maximum
$info.CpuMaxValue=$max
Write-Host "Maximum $max" -ForegroundColor Yellow `n




#Commited Bytes
Write-Host "Committed Bytes In Use" -ForegroundColor Green

$memoryused=Get-Counter -Counter "\Memory\% Committed Bytes In Use" -SampleInterval 2 -MaxSamples 5
$info.MemUsedTimeStamp=$memoryused.Timestamp[0]
$memoryusedvalue=$memoryused.Countersamples.cookedvalue


$average=($memoryusedvalue | Measure-Object -Average).average
$info.MemUsedAvg=$average
Write-Host " Average $average" -ForegroundColor Yellow


$min=($memoryusedvalue | Measure-Object -Minimum).Minimum
$info.MemUsedMin=$min
Write-Host "Minimum $min" -ForegroundColor Yellow


$max=($memoryusedvalue | Measure-Object -Maximum ).Maximum
$info.MemUsedMax=$max
Write-Host "Maximum $max" -ForegroundColor Yellow `n





#Available MBytes
Write-Host "Available MBytes" -ForegroundColor Green

$avlmem=Get-Counter -Counter "\Memory\Available MBytes" -SampleInterval 2 -MaxSamples 5
$avlmemtimestamp=$avlmem.Timestamp
$info.AvailMemTimeStamp=$avlmemtimestamp[0]

$avlmemvalue=$avlmem.Countersamples.cookedvalue


$average=($avlmemvalue | Measure-Object -Average).average
$info.AvailMemAvg=$average
Write-Host " Average $average" -ForegroundColor Yellow

$min=($avlmemvalue| Measure-Object -Minimum).Minimum
$info.AvailMemMin=$min
Write-Host "Minimum $min" -ForegroundColor Yellow

$max=($avlmemvalue | Measure-Object -Maximum ).Maximum
$info.AvailMemMax=$max
Write-Host "Maximum $max" -ForegroundColor Yellow `n


#Avg. Disk sec/Write
Write-Host "Avg. Disk sec/Write" -ForegroundColor Green

$dskwrte=Get-Counter -Counter "\LogicalDisk(*)\Avg. Disk sec/Write" -SampleInterval 2 -MaxSamples 5
$dskwrtetimestamp=$dskwrte.Timestamp[0]
$info.DiskWriteTimestamp=$dskwrtetimestamp


$dskwrtevalue=$avlmem.Countersamples.cookedvalue

$average=($dskwrtevalue | Measure-Object -Average).average
$info.DiskWriteAvg=$average
Write-Host " Average $average" -ForegroundColor Yellow

$min=($dskwrtevalue| Measure-Object -Minimum).Minimum
$info.DiskWriteMin=$min
Write-Host "Minimum $min" -ForegroundColor Yellow

$max=($dskwrtevalue | Measure-Object -Maximum ).Maximum
$info.DiskWriteMax=$max
Write-Host "Maximum $max" -ForegroundColor Yellow `n


#Avg. Disk sec/Read
Write-Host "Avg. Disk sec/Read" -ForegroundColor Green

$diskread=Get-Counter -Counter "\LogicalDisk(*)\Avg. Disk sec/Read" -SampleInterval 2 -MaxSamples 5
$diskreadtimestamp=$diskread.Timestamp[0]
$info.DiskReadTimestamp=$diskreadtimestamp

$diskreadvalue=$diskread.Countersamples.cookedvalue

$average=($diskreadvalue | Measure-Object -Average).average
$info.DiskReadAvg=$average
Write-Host "Average $average" -ForegroundColor Yellow


$min=($diskreadvalue| Measure-Object -Minimum).Minimum
$info.DiskReadMin=$min
Write-Host "Minimum $min" -ForegroundColor Yellow


$max=($diskreadvalue | Measure-Object -Maximum ).Maximum
$info.DiskReadMax=$max
Write-Host "Maximum $max" -ForegroundColor Yellow `n



Write-Host "Free Space" -ForegroundColor Green
#Free Space
$free=Get-Counter -Counter "\LogicalDisk(*)\% Free Space" -SampleInterval 2 -MaxSamples 10
$freetimestamp=$free.Timestamp[0]
$info.FreeSpaceTimestamp=$freetimestamp

$freevalue=$free.Countersamples.cookedvalue

$average=($freevalue| Measure-Object -Average).average
$info.FreeSpaceAvg=$average
Write-Host " Average $average" -ForegroundColor Yellow


$min=($freevalue| Measure-Object -Minimum).Minimum
$info.FreeSpaceMin=$min
Write-Host "Minimum $min" -ForegroundColor Yellow


$max=($freevalue | Measure-Object -Maximum ).Maximum
$info.FreeSpaceMax=$max
Write-Host "Maximum $max" -ForegroundColor Yellow




$report+=$info



$performance=$report 
foreach($perf in $performance) 
{ 
$CpuTimeStamp=$perf.CpuTimeStamp
$CpuAverageValue=$perf.CpuAverageValue
$CpuMinValue=$perf.CpuMinValue
$CpuMaxValue=$perf.CpuMaxValue
$MemUsedTimeStamp=$perf.MemUsedTimeStamp
$MemUsedAvg=$perf.MemUsedAvg
$MemUsedMin=$perf.MemUsedMin
$MemUsedMax=$perf.MemUsedMax
$AvailMemTimeStamp=$perf.AvailMemTimeStamp
$AvailMemAvg=$perf.AvailMemAvg
$AvailMemMin=$perf.AvailMemMin
$AvailMemMax=$perf.AvailMemMax
$DiskWriteTimestamp=$perf.DiskWriteTimestamp
$DiskWriteAvg=$perf.DiskWriteAvg
$DiskWriteMin=$perf.DiskWriteMin
$DiskWriteMax=$perf.DiskWriteMax
$DiskReadTimestamp=$perf.DiskReadTimestamp
$DiskReadAvg=$perf.DiskReadAvg
$DiskReadMin=$perf.DiskReadMin
$DiskReadMax=$perf. DiskReadMax
$FreeSpaceTimestamp=$perf.FreeSpaceTimestamp
$FreespaceAvg=$perf.FreespaceAvg
$FreespaceMin=$perf.FreespaceMin
$FreespaceMax=$perf.FreespaceMax
$disname=$service.DisplayName 
 
$insertquery=" 
INSERT INTO [dbo].[PerformanceMonitorup] 
           ([CpuTimeStamp] 
           ,[CpuAverageValue] 
           ,[CpuMinValue]
           ,[CpuMaxValue]
           ,[MemUsedTimeStamp]
           ,[MemUsedAvg]
           ,[MemUsedMin]
           ,[MemUsedMax]
           ,[AvailMemTimeStamp]
           ,[AvailMemAvg]
           ,[AvailMemMin]
           ,[AvailMemMax]
           ,[DiskWriteTimestamp]
           ,[DiskWriteAvg]
           ,[DiskWriteMin]
           ,[DiskWriteMax]
           ,[DiskReadTimestamp]
           ,[DiskReadAvg]
           ,[DiskReadMin]
           ,[DiskReadMax]
           ,[FreeSpaceTimestamp]
           ,[FreespaceAvg]
           ,[FreespaceMin]
           ,[FreespaceMax]) 
     VALUES 
           ('$CpuTimeStamp' 
           ,'$CpuAverageValue' 
           ,'$CpuMinValue'
           ,'$CpuMaxValue'
           ,'$MemUsedTimeStamp'
           ,'$MemUsedAvg'
           ,'$MemUsedMin'
           ,'$MemUsedMax'
           ,'$AvailMemTimeStamp'
           ,'$AvailMemAvg'
           ,'$AvailMemMin'
           ,'$AvailMemMax'
           ,'$DiskWriteTimestamp'
           ,'$DiskWriteAvg'
           ,'$DiskWriteMin'
           ,'$DiskWriteMax'
           ,'$DiskReadTimestamp'
           ,'$DiskReadAvg'
           ,'$DiskReadMin'
           ,'$DiskReadMax'
           ,'$FreeSpaceTimestamp'
           ,'$FreespaceAvg'
           ,'$FreespaceMin'
           ,'$FreespaceMax') 
 
" 
 


$server = "sqlvmpro.eastus.cloudapp.azure.com" 
$database = "Performanceupdated" 
$adminName = "proloy" 
$adminPassword = "6punkrude*******" 

$ConnectionString="Data Source=$server,1433;database=$database;User ID=$adminName;Password=$adminPassword;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;TrustServerCertificate=True";
$sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString;
$sqlConnection.Open();

$sql = $insertquery
$cmd = new-object System.Data.SqlClient.SqlCommand 
$cmd.Connection = $sqlConnection
$cmd.CommandText = $sql
$cmd.CommandTimeout = 600
$cmd.ExecuteNonQuery()
$sqlConnection.Close()
}


