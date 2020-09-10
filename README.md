# powerSQL
## This module allows you to insert and update rows within SQL without having to make changes.
### Run INstall-Module PowerSQL while placing the module files in a folder called PowerSQL within your modules folder.
```
$csvfile = Import-Csv .\file.csv
$test = Convert-CSVtoSQL -csv $csvfile -statement "Insert" -table "table1"
$test2 = Convert-ObjectToSQL -item $csvfile[0] -statement "insert" -table "table1"
$test3 = Convert-ObjectToSQLUpdate -item $csvfile[0] -matchColumn "id" -table "table1"
$test4 = Convert-CSVtoSQLUpdate -csv $csvfile -matchColumn "id" -table "table1"
```
