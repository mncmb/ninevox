# install choco tools 
Write-Host "setting up dev utils"
choco install -y --limit-output --no-progress 7zip apimonitor dependencywalker die dnspy explorersuite firefox ghidra hxd pebear processhacker x64dbg.portable
choco install -y --limit-output --no-progress git golang python3 nuget.commandline vcredist-all vcredist140 vscode notepadplusplus windows-sdk-10-version-2004-windbg
Write-Host "installing Visual Studio native package. This will take a while"
Write-Host "..."
choco install -y --limit-output --no-progress visualstudio2022-workload-nativedesktop
#########################################################################################
$devdir = $($HOME+'\Desktop\devx')
md -Force $devdir
# add exclusion for directory
Add-MpPreference -ExclusionPath $devdir
Remove-MpPreference -ExclusionPath "C:\"
# disable automatic sample submission --- never submit, never ask
#    Set-MpPreference -SubmitSamplesConsent 2
# Always prompt - Automatic sample submission - ON 
# this option is the default value for disabling
# we get info that defender wants to submit something and deems it suspicious
Set-MpPreference -SubmitSamplesConsent 0

# install pyinstaller
pip install pyinstaller pyarmor

# these are required to compile ThreatCheck and probably other stuff
nuget sources add -Source https://www.nuget.org/api/v2/ 2>$null 



#########################################################################################
# refresh chocolety environment
refreshenv
cd $devdir

git clone -q https://github.com/S3cur3Th1sSh1t/Amsi-Bypass-Powershell 
git clone -q https://github.com/RythmStick/AMSITrigger
git clone -q https://github.com/danielbohannon/Invoke-Obfuscation
git clone -q https://github.com/cobbr/SharpSploit
git clone -q https://github.com/rasta-mouse/ThreatCheck
git clone -q https://github.com/mgeeky/PackMyPayload
git clone -q https://github.com/vyrus001/ebowla-2
git clone -q --recurse https://github.com/mgeeky/ProtectMyTooling
git clone -q https://github.com/Aetsu/OffensivePipeline

# download latest confuserEx release
iwr -useb https://github.com/mkaring/ConfuserEx/releases/latest/download/ConfuserEx.zip -o ConfuserEx.zip

# download latest macroPack
iwr -useb https://github.com/sevagas/macro_pack/releases/latest/download/macro_pack.exe -o macro_pack.exe

###############################
# TO BUILD SOMETHING
###############################
# open DEVELOPER command prompt
# cd AMSITrigger # or whatever
# nuget restore         ### fixes dependencies and loads missing packages
# msbuild /p:Configuration=Release


#########################################################################################
mkdir Tools
cd Tools
git clone -q https://github.com/vyrus001/go-mimikatz
git clone -q https://github.com/mkaring/ConfuserEx
git clone -q https://github.com/GhostPack/Rubeus
git clone -q https://github.com/GhostPack/Seatbelt
git clone -q https://github.com/rasta-mouse/Watson
git clone -q https://github.com/GhostPack/SharpUp
git clone -q https://github.com/S3cur3Th1sSh1t/PowerSharpPack
# https://github.com/Flangvik/SharpCollection
# https://github.com/S3cur3Th1sSh1t/PowerSharpPack