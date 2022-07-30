# set powershell script block logging
# requires restart 
function Set-ScriptBlockLogging {
	Write-Host "setting script block logging"
	new-Item -path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -force
	set-ItemProperty -path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -name "EnableScriptBlockLogging" -Value 1
	set-ItemProperty -path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -name "EnableScriptBlockInvocationLogging" -Value 1
	Write-Host "script block logging set"
}

function Set-TaskHistory {
	Write-Host "setting task history"
	wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true
	Write-Host "task history set"
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
	New-TempWorkingDir
	$sysmon = "sysmon.exe"
	if (!(Test-path $sysmon)) {
		iwr -usebasicparsing -outfile $sysmon https://live.sysinternals.com/Sysmon64.exe
		iwr -usebasicparsing -outfile "sysmon-config.xml" https://raw.githubusercontent.com/Neo23x0/sysmon-config/master/sysmonconfig-export.xml
		.\sysmon.exe -i .\sysmon-config.xml -accepteula 2>$null # this always errors even if it is succesful and vagrant flips out about it 
		Write-Host "finished downloading and installing sysmon and config"
		rm sysmon.exe 
		rm sysmon-config.xml
	} else 
	{
		Write-Host "$sysmon already existed. Skipping redownload"
	}
}


function Invoke-Zimmer {
	Write-Host "downloading Zimmerman tools"
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
	Write-Host "finished downloading Zimmerman tools"
}
# 

function Invoke-Sysinternals {
	Write-Host "downloading sysinternals"
    $dlsysint = "sysinternals.zip"
	New-TempWorkingDir
	if (!(test-path $dlsysint)) {
		iwr -UseBasicParsing -outfile $dlsysint https://download.sysinternals.com/files/SysinternalsSuite.zip
    	Write-Host "extracting sysinternals"
		Expand-Archive -Force $dlsysint
		Write-Host "finished sysinternals"
	} else {
		Write-Host "$dlsysint already existed. Skipping redownload"
	}
}


function Get-Powersiem {
	Write-Host "downloading powersiem"
	New-TempWorkingDir
	iwr -usebasicparsing -outfile "sysmon-config.xml" https://raw.githubusercontent.com/Neo23x0/sysmon-config/master/sysmonconfig-export.xml
	Write-Host "finished downloading powersiem"
}

function Invoke-Systools {
	Set-ScriptBlockLogging
    Set-TaskHistory
	Invoke-Swiftmon
	Invoke-Zimmer
	Invoke-Sysinternals
	Get-Powersiem
}

Invoke-Systools