# Throw in $Profile.AllUsersAllHosts


Import-Module posh-git
Import-Module AWSPowerShell.NetCore
Set-DefaultAWSRegion -Region us-east-1

function GetEC2InstanceByName($InstanceNameFilter) {
    $InstancesObject = @()
    $Instances = (Get-EC2Instance -Filter @( @{name='tag:Name'; values="$InstanceNameFilter"})).Instances
    
    ForEach ($Instance in $Instances) {    
        $InstanceName = $Instance.tags | where-object key -eq "Name" | Select-Object Value -expand Value
        $InstanceIP = $Instance | Select-Object -ExpandProperty PrivateIpAddress
  
        $InstancesObject += [pscustomobject][ordered]@{
            InstanceId = $Instance.InstanceId
            InstanceName = $InstanceName
            InstanceIP = $InstanceIP
        }
    }
    return $InstancesObject | sort-object InstanceName
  }