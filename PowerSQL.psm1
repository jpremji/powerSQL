
<#
.SYNOPSIS
 This script will contain functions to interact with SQL.
.DESCRIPTION
 This is for anyone who needs to insert and update items for SQL.
.PARAMETER <Parameter_Name>
    Parameters are not required for this script. 
.INPUTS
  <Inputs if any, otherwise state None>
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
.NOTES
  Version:        1.0
  Author:         Jamil Premji
  Creation Date:  2020-09-09
  Purpose/Change: Initial script development
  
.EXAMPLE
 
#>

#C:\Windows\System32\WindowsPowerShell\v1.0\Modules
#$manifest = @{
    #Path              = '.\PowerSQL\PowerSQL.psd1'
    #RootModule        = 'PowerSQL.psm1' 
    #Author            = 'Jamil Premji'
    #Description            = 'PowerSQL'
#}
#New-ModuleManifest @manifest
#Update-ModuleManifest @manifest

 #https://vwiki.co.uk/MySQL_and_PowerShell

function Send-MySQLNonQuery($conn, [string]$query) { 
  $command = $conn.CreateCommand()                  # Create command object
  $command.CommandText = $query                     # Load query into object
  $RowsInserted = $command.ExecuteNonQuery()        # Execute command
  $command.Dispose()                                # Dispose of command object
  if ($RowsInserted) { 
    return $RowInserted 
  } else { 
    return $false 
  } 
} 

 #https://vwiki.co.uk/MySQL_and_PowerShell

function Connect-MySQL([string]$user, [string]$pass, [string]$MySQLHost, [string]$database) { 
    # Load MySQL .NET Connector Objects 
    [void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data") 
 
    # Open Connection 
    $connStr = "server=" + $MySQLHost + ";port=3306;uid=" + $user + ";pwd=" + $pass + ";database="+$database+";Pooling=FALSE" 
    try {
        $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr) 
        $conn.Open()
    } catch [System.Management.Automation.PSArgumentException] {
        Write-Host "Unable to connect to MySQL server, do you have the MySQL connector installed..?"
        Write-Host $_
        Exit
    } catch {
        Write-Host "Unable to connect to MySQL server..."
        Write-Host $_.Exception.GetType().FullName
        Write-Host $_.Exception.Message
        exit
    }
    Write-Host "Connected to MySQL database $MySQLHost\$database"

    return $conn 
}




function Convert-ObjectToSQL () {
Param(
 
 [parameter(position=0)]
 $item,
 [parameter(position=1)]
 $statement,
 [parameter(position=2)]
 $table
 
 )
    $names = $item[0].psobject.properties  | select name
    $columns = $names.name -join ","
    $count = $names.Count
    $rows = ""
    $i = 0
        while ($i -lt $count) {
            $data = $item[0].$($names[$i].Name)
            if ($data -is [int]) {
                $rows = $rows + "," + $data
            }
            else {
                $rows = $rows + ",'" + $data + "'"
            }
            $i++
        }
        $rows = $rows.Substring(1)
        $rows = "(" + $rows + ")"
        $columns = "(" + $columns + ")"
        $rows = $rows.Replace('`','\u0027')
        $query = "INSERT INTO tvmaze " + $columns + " VALUES " + $rows
        $query
}





function Convert-CSVtoSQL () {
Param(
 
 [parameter(position=0)]
 $csv,
 [parameter(position=1)]
 $statement,
 [parameter(position=2)]
 $table
 
 )
 
    $returnObj = @()
    $names = $csv | Get-Member -MemberType 'NoteProperty' | Select Name
    $columns = $names.name -join ","
    foreach ($item in $csv) {   
    $count = $names.Count
    $rows = ""
    $i = 0
        while ($i -lt $count) {
            $data = $item[0].$($names[$i].Name)
            if ($data -is [int]) {
                $rows = $rows + "," + $data
            }
            else {
                $rows = $rows + ",'" + $data + "'"
            }
            $i++
        }
        $rows = $rows.Substring(1)
        $rows = "(" + $rows + ")"
        $columns = "(" + $columns + ")"
        $rows = $rows.Replace('`','\u0027')
        $query = $statement + " INTO " + $table  + " " + $columns + " VALUES " + $rows
        $returnObj += $query
    }
    $returnObj
}
function Convert-CSVtoSQLUpdate () {
Param(
 
 [parameter(position=0)]
 $csv,
 [parameter(position=1)]
 $matchColumn,
 [parameter(position=2)]
 $table
 )
    $returnObj = @()
    $names = $csv[0].psobject.properties  | select name
    $columns = $names.name -join ","
    $count = $names.Count
    #$columns
    foreach ($item in $csv) {
        $string = ''
        $i = 0
        while ($i -lt $count) {
            $data =  $item.($names.Name[$i]) 
            if ($data -match '^[0-9]+$') {
                $string += '`' + $names.Name[$i] + '`=' + $data + ', '
                $i++
            }
            else {
                $string += '`' + $names.Name[$i] + '`=''' + $data + ''', '
                $i++
            }
        }
        $matchValue = $item.($matchColumn)
        $string = $string.Substring(0,$string.Length-2)
        $query = 'UPDATE `' + $table + '` SET ' + $string + ' WHERE `id`=' + $matchValue
        $returnObj += $query
    }
    $returnObj

}

function Convert-ObjectToSQLUpdate () {
Param(
 
 [parameter(position=0)]
 $item,
 [parameter(position=1)]
 $matchColumn,
 [parameter(position=2)]
 $table
 )
   $names = $item[0].psobject.properties  | select name
    $columns = $names.name -join ","
    $count = $names.Count
    $i = 0
    $string = ''
    while ($i -lt $count) {
        $data =  $item.($names.Name[$i]) 
        if ($data -match '^[0-9]+$') {
            $string += '`' + $names.Name[$i] + '`=' + $data + ', '
            $i++
        }
        else {
            $string += '`' + $names.Name[$i] + '`=''' + $data + ''', '
            $i++
        }
    }
    $matchValue = $item.($matchColumn)
    $string = $string.Substring(0,$string.Length-2)
    $query = 'UPDATE `' + $table + '` SET ' + $string + ' WHERE `id`=' + $matchValue
    $query
}

