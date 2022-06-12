# install choco tools 
Write-Host "setting up dev utils"
choco install -y --limit-output --no-progress NotepadPlusPlus 7zip apimonitor dependencywalker die dnspy explorersuite firefox ghidra git golang hxd notepadplusplus nuget.commandline pebear processhacker python3 vcredist-all vcredist140 visualstudio2019-workload-nativedesktop vscode windows-sdk-10-version-2004-windbg x64dbg.portable 

# --------------------------------------
$devdir = $($HOME+'\Desktop\devx')
md -Force $devdir
# add exclusion for directory
Add-MpPreference -ExclusionPath $devdir
Remove-MpPreference -ExclusionPath "C:\"
# disable automatic sample submission --- never submit, never ask
# Set-MpPreference -SubmitSamplesConsent 2
# Always prompt - Automatic sample submission - ON
Set-MpPreference -SubmitSamplesConsent 0

cd $devdir

git clone https://github.com/S3cur3Th1sSh1t/Amsi-Bypass-Powershell 
git clone https://github.com/danielbohannon/Invoke-Obfuscation
git clone https://github.com/RythmStick/AMSITrigger
git clone https://github.com/rasta-mouse/ThreatCheck
git clone https://github.com/GhostPack/Rubeus
git clone https://github.com/cobbr/SharpSploit
git clone https://github.com/GhostPack/Seatbelt
git clone https://github.com/GhostPack/SharpUp
# these are required to compile ThreatCheck
nuget sources add -Source https://www.nuget.org/api/v2/

# open DEVELOPER command prompt
# cd AMSITrigger # or whatever
# nuget restore # fixes dependencies and loads missing packages
# msbuild /p:Configuration=Release