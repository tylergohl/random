# Start-OpsViewMaint.ps1
# v0.1
# T.J. Gohl
# tjgohl@gmail.com



Param (
  
  [parameter(Mandatory=$true, ValueFromPipeline=$true)]
  [ValidateScript({Resolve-DNSName $_})]
  [String[]]
  $hostname
)

Begin {
  
  $opsurl = 'https://opsviewurl.company.com/rest'
  $username = '#####'
  $login = @{
        'username' = $username
        'password' = '#####'
  
  }
}

process {
  
  foreach ($opsviewhost in $hostname) { 	
	
	$token = Invoke-RestMethod -Method Post -Uri "$opsurl/login" -body $login
    $downtimebody = '{"starttime":"now","endtime":"+1h","comment":"REST Maintenance"}'
    Invoke-RestMethod -Method Post -Uri "$opsurl/downtime?host=$opsviewhost" -Headers @{"X-Opsview-Username"="$username";"X-Opsview-Token"="$($token.token)"} -body $downtimebody -contentType "application/json"  
  
  }
}