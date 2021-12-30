
$filename = "*.json"

$searchinfolder = "C:\Users\Gulab\Desktop\resourceId=\"

$FilenName = "C:\Users\Gulab\Desktop\resourceId=\WAF-Metrics-"

$AllF = Get-ChildItem -Path $searchinfolder -Filter $filename -Recurse | %{$_.FullName}

Foreach ($AllJson in $AllF)
    
        {

            $S0 = $AllJson.Split("\")[5]
            $S1 =  $AllJson.Split("\")[6]

            $Final = $S0 + $S1

            $Outputfile = $FilenName + $Final + ".csv"


            Get-Content -Path $AllJson  | ConvertFrom-Json | ConvertTo-Csv -NoTypeInformation | Set-Content $Outputfile       
  

        }

       


