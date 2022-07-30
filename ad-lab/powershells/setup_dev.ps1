.\generic_setup.ps1
# install choco tools 
choco install -y 7zip apimonitor dependencywalker die dnspy explorersuite firefox ghidra git golang hxd notepadplusplus nuget.commandline pebear processhacker python3 vcredist-all vcredist140 visualstudio2019-workload-nativedesktop vscode windows-sdk-10-version-2004-windbg x64dbg.portable 

# --------------------------------------
$devdir = $($HOME+'\Desktop\xdev')
md -Force $devdir
# add exclusion for directory
Add-MpPreference -ExclusionPath $devdir
# disable automatic sample submission --- never submit, never ask
# Set-MpPreference -SubmitSamplesConsent 2
# Always prompt - Automatic sample submission - ON
Set-MpPreference -SubmitSamplesConsent 0
cd $devdir
git clone https://github.com/S3cur3Th1sSh1t/Amsi-Bypass-Powershell
git clone https://github.com/danielbohannon/Invoke-Obfuscation
git clone https://github.com/RythmStick/AMSITrigger
git clone https://github.com/rasta-mouse/ThreatCheck

# these are required to compile ThreatCheck
nuget sources add -Source https://www.nuget.org/api/v2/

# open DEVELOPER command prompt
# cd AMSITrigger # or whatever
# nuget restore # fixes dependencies and loads missing packages
# msbuild /p:Configuration=Release