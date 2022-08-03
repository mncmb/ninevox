# install choco tools 
Write-Host "setting up dev utils"
choco install -y --limit-output --no-progress NotepadPlusPlus 7zip apimonitor dependencywalker die dnspy explorersuite firefox ghidra git golang hxd notepadplusplus nuget.commandline pebear processhacker python3 vcredist-all vcredist140 visualstudio2022-workload-nativedesktop vscode windows-sdk-10-version-2004-windbg x64dbg.portable 

# --------------------------------------
$devdir = $($HOME+'\Desktop\devx')
md -Force $devdir
# add exclusion for directory
Add-MpPreference -ExclusionPath $devdir
Remove-MpPreference -ExclusionPath "C:\"
# disable automatic sample submission --- never submit, never ask
#    Set-MpPreference -SubmitSamplesConsent 2
# Always prompt - Automatic sample submission - ON 
# this option is default so we get info that defender wants to submit something
Set-MpPreference -SubmitSamplesConsent 0

refreshenv
cd $devdir

git clone -q https://github.com/S3cur3Th1sSh1t/Amsi-Bypass-Powershell 
git clone -q https://github.com/RythmStick/AMSITrigger
git clone -q https://github.com/mkaring/ConfuserEx
git clone -q https://github.com/vyrus001/go-mimikatz
git clone -q https://github.com/danielbohannon/Invoke-Obfuscation
git clone -q https://github.com/GhostPack/Rubeus
git clone -q https://github.com/GhostPack/Seatbelt
git clone -q https://github.com/cobbr/SharpSploit
git clone -q https://github.com/GhostPack/SharpUp
git clone -q https://github.com/rasta-mouse/ThreatCheck
git clone -q https://github.com/rasta-mouse/Watson

# download latest confuserEx release
iwr -useb https://github.com/mkaring/ConfuserEx/releases/latest/download/ConfuserEx.zip -o ConfuserEx.zip

# install pyinstaller
pip install pyinstaller


# https://github.com/Flangvik/SharpCollection
# https://github.com/S3cur3Th1sSh1t/PowerSharpPack

# these are required to compile ThreatCheck
nuget sources add -Source https://www.nuget.org/api/v2/ 2>$null 

# open DEVELOPER command prompt
# cd AMSITrigger # or whatever
# nuget restore # fixes dependencies and loads missing packages
# msbuild /p:Configuration=Release