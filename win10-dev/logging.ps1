# set powershell script block logging
# requires restart 
function Set-ScriptBlockLogging {
	Write-Host "setting script block logging"
	try {
		new-Item -path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -force
		set-ItemProperty -path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -name "EnableScriptBlockLogging" -Value 1
		set-ItemProperty -path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -name "EnableScriptBlockInvocationLogging" -Value 1
	}
	catch {
		Write-Host "An error occurred:"
  		Write-Host $_
	}
}

function Set-TaskHistory {
	Write-Host "setting task history"
	try {
		wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true
	}
	catch {
		Write-Host "An error occurred:"
  		Write-Host $_
	}
}

function New-TempWorkingDir {
	$workingDir=$HOME+"\Desktop\"
	cd $workingDir
	md -Force SysTools
	cd SysTools
}

# install sysmon with swifton security configls
# https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml
# alternatively use this https://raw.githubusercontent.com/Neo23x0/sysmon-config/master/sysmonconfig-export.xml
function Invoke-Swiftmon {
	Write-Host "downloading and installing sysmon and config"
	try {
		New-TempWorkingDir
		$sysmon = "sysmon.exe"
		if (!(Test-path $sysmon)) {
			iwr -usebasicparsing -outfile $sysmon https://live.sysinternals.com/Sysmon64.exe
			iwr -usebasicparsing -outfile "sysmon-config.xml" https://raw.githubusercontent.com/Neo23x0/sysmon-config/master/sysmonconfig-export.xml
			.\sysmon.exe -i .\sysmon-config.xml -accepteula
		} else 
		{
			Write-Host "$sysmon already existed. Skipping redownload"
		}
	} 
	catch {
		Write-Host "An error occurred:"
  		Write-Host $_
	}
}


function Invoke-Zimmer {
	Write-Host "downloading Zimmerman tools"
	try {
		New-TempWorkingDir
		$dldir = "ZimmermanTools"
		if (!(test-path $dldir)) {
			mkdir $dldir
			cd $dldir
			iex(iwr -UseBasicParsing https://raw.githubusercontent.com/EricZimmerman/Get-ZimmermanTools/master/Get-ZimmermanTools.ps1)
		} else 
		{
			Write-Host "$dldir already existed. Skipping redownload"
		}
	}
	catch {
		Write-Host "An error occurred:"
  		Write-Host $_
	}
}
# 

function Invoke-Sysinternals {
	Write-Host "downloading sysinternals"
    $dlsysint = "sysinternals.zip"
	try {
		New-TempWorkingDir
		if (!(test-path $dlsysint)) {
			iwr -UseBasicParsing -outfile $dlsysint https://download.sysinternals.com/files/SysinternalsSuite.zip
    		Write-Host "extracting sysinternals"
			Expand-Archive -Force $dlsysint
		} else {
			Write-Host "$dlsysint already existed. Skipping redownload"
		}
	}
	catch {
		Write-Host "An error occurred:"
  		Write-Host $_
	}
}

function Invoke-Systools {
	Set-ScriptBlockLogging
    Set-TaskHistory
	Invoke-Swiftmon
	Invoke-Zimmer
	Invoke-Sysinternals
}

Invoke-Systools