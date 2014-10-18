# Start-OpsViewMaint.ps1
# v0.2
# T.J. Gohl
# tjgohl@gmail.com

Param (
  
  [parameter(Mandatory=$true, ValueFromPipeline=$true)]
# [ValidateScript({Resolve-DNSName $_})]
  [String[]]
  $Hostname,
  
  [parameter(Mandatory=$false)]
  [Int]
  $MaintMinutes = 60,
  
  [parameter(Mandatory=$false)]
  [String]
  $Comment = "Scripted REST Maintenance"
  
)



Begin {
  
  $opsurl = 'https://opsviewurl.company.com/rest'
  $username = 'opsviewaccount'
  $login = @{
        'username' = $username
        'password' = 'your_password'
  }
   
  $MaintMinutesString = $MaintMinutes -as [string]  
  $MaintMinutesString = $MaintMinutesString.Insert(0,"+") + "m"
  
}

process {
  
  foreach ($opsviewhost in $hostname) { 	
	
	$token = Invoke-RestMethod -Method Post -Uri "$opsurl/login" -body $login
	$downtimebody = @{
	  starttime = "now"
	  endtime = $MaintMinutesString
	  comment = $Comment
    }

	$downtimebody = $downtimebody | convertto-json -compress

    $result = Invoke-RestMethod -Method Post -Uri "$opsurl/downtime?host=$opsviewhost" -Headers @{"X-Opsview-Username"="$username";"X-Opsview-Token"="$($token.token)"} -body $downtimebody -contentType "application/json"  
    
    if ($result.summary.num_hosts -gt 0) {
      write-host "$($result.list.hosts.hostname) successfully placed into maintenance mode for $MaintMinutes minute(s)!" -foregroundcolor "green"
    }
  }
}