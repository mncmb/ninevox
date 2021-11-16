


function CreateShortcut {

    param (
        $Executable,
        $Output
    )

    #$filename = [io.path]::GetFileNameWithoutExtension($Executable)
    $TargetFile = $Executable#"C:\ProgramData\chocolatey\bin\" + $filename + ".exe"
    
    if (![System.IO.File]::Exists($TargetFile))
    {
        Write-Error "File name $TargetFile does not exist"
        return
    }


    # $ShortcutFile = [Environment]::GetFolderPath("Desktop") + "\" + $filename + ".lnk"
    $ShortcutFile = $Output#[Environment]::GetFolderPath("CommonDesktopDirectory") + "\" + $filename + ".lnk"


    # create shortcut
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Save()
    Write-Host  "[INFO] `"$ShortcutFile`" created."
}



CreateShortcut $args[0] $args[1]