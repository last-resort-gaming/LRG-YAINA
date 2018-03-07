<#

stop.ps1

we use stop as terminating the instance doesn't kick players and they just get a
"No message received for X seconds" popping up which is rather ugly, so by using
the CloseMainWindow() it's equivalent to us clicking it and they then get a
"Session Lost" pop up and go back to server list

#>

param (
	[Parameter(Mandatory=$true)][string]$instance
)

Get-WmiObject Win32_Process | select name, processID, commandline | ? {
	if($_.Name -Match "arma3server_x64") {
		$A3Pid = $_.processID
			$_.CommandLine.Split(" ") | ? {
				if ($_ -Match "-yainaInstance=$instance") {
					Get-Process -Id $A3Pid | ? {
					$_.CloseMainWindow() | Out-Null
				}
			}
		}
	}
}