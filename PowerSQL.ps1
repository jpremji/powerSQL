
Install-Module -Name PowerSQL -Scope CurrentUser -ErrorAction SilentlyContinue  -Force
Test-ModuleManifest -Path C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PowerSQL\PowerSQL.psd1
#Requires -Modules PowerSQL
$csvfile = Import-Csv .\file.csv
$test = Convert-CSVtoSQL -csv $csvfile -statement "Insert" -table "table1"
$test2 = Convert-ObjectToSQL -item $csvfile[0] -statement "insert" -table "table1"
$test3 = Convert-ObjectToSQLUpdate -item $csvfile[0] -matchColumn "id" -table "table1"
$test4 = Convert-CSVtoSQLUpdate -csv $csvfile -matchColumn "id" -table "table1"