param ([String] $name)
choco install -y --limit-output --no-progress bginfo
$path1="c:\vagrant"
$path2="\\VBOXSVR\vagrant"

# since some interactions between scripts or programs are weird because vagrant uses some kind of winrm shell, 
# some programs have to be started in other ways (eg sched task)
function Set-WP([String] $name, [String] $sharepath) {
    $currentDir=pwd
    Write-host "set-wp called with $name and $sharepath"
    mkdir c:\bginfo
    cd c:\bginfo
    cp $sharepath\resources\windows\$name.bgi .
    cp $sharepath\resources\windows\$name-wallpaper.jpg wallpaper.jpg
    cd $currentDir

    $cmd = "Bginfo64.exe c:\bginfo\$name.bgi /timer:0"
    Write-host "running task as $(whoami)"
    schtasks.exe /CREATE /F /TN "RunScriptOnce" /RU $(whoami) /SC ONSTART /TR "$cmd"
    Start-Sleep -s 1
    schtasks.exe /RUN /TN "RunScriptOnce"
    Start-Sleep -s 1
    schtasks.exe /DELETE /F /TN "RunScriptOnce"
}

if (!(test-path c:\bginfo )) {
    if (test-path $path1) {
        Set-WP $name $path1
    }
    else {
        if (test-path $path2){
           Set-WP $name $path2
        }
        else {
            Write-host "Files not mapped under default locations"
        }
    }
}
else
{
    Write-host "BGInfo dir already existed, skipping setting wallpaper"
}




