param ([String] $name)
choco install -y --limit-output --no-progress bginfo
if (!(test-path c:\bginfo )) {
    mkdir c:\bginfo
    cd c:\bginfo
    cp c:\vagrant\resources\windows\dev.bgi .
    cp c:\vagrant\resources\windows\$name-wallpaper.jpg wallpaper.jpg
    bginfo .\dev.bgi  /timer:0
}
else
{
    Write-host "BGInfo dir already existed, skipping setting wallpaper"
}
