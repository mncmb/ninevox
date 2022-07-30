# set powershell script block logging
# requires restart 
function Set-ScriptBlockLogging {
	new-Item -path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -force
	set-ItemProperty -path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -name "EnableScriptBlockLogging" -Value 1
	set-ItemProperty -path 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -name "EnableScriptBlockInvocationLogging" -Value 1
}

function Set-TaskHistory {
	wevtutil set-log Microsoft-Windows-TaskScheduler/Operational /enabled:true
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
	New-TempWorkingDir
	iwr -usebasicparsing -outfile sysmon.exe https://live.sysinternals.com/Sysmon64.exe
	iwr -usebasicparsing -outfile sysmon-config.xml https://raw.githubusercontent.com/Neo23x0/sysmon-config/master/sysmonconfig-export.xml
	.\sysmon.exe -i .\sysmon-config.xml -accepteula
}


function Invoke-Zimmer {
	New-TempWorkingDir
	$dldir = "ZimmermanTools"
	mkdir $dldir
	cd $dldir
	iex(iwr -UseBasicParsing https://raw.githubusercontent.com/EricZimmerman/Get-ZimmermanTools/master/Get-ZimmermanTools.ps1)
}
# 

function Invoke-Sysinternals {
    $dlsysint = "sysinternals.zip"
	New-TempWorkingDir
	iwr -UseBasicParsing -outfile $dlsysint https://download.sysinternals.com/files/SysinternalsSuite.zip
    Expand-Archive $dlsysint
}

function Invoke-Systools {
	Set-ScriptBlockLogging
    Set-TaskHistory
	Invoke-Swiftmon
	Invoke-Zimmer
	Invoke-Sysinternals
}

Invoke-Systools