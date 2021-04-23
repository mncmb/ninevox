<#
    create_choco_shortcut.ps1 
    
    call script like:

        create_choco_shortcut.ps1 PE-bear

    call with multiple args to create multiple shortcuts at once:

         create_choco_shortcut.ps1 PE-bear pestudio x32dbg x64dbg


    To create a shortcut from chocolatey default install directory the shortcut 
    will be put on the Desktop of all Users via the 'Public desktop' directory.
    script prints an error if the filename does not exist inside the choco dir

#>


function CreateShortcut {

    param (
        $Executable
    )

    $filename = [io.path]::GetFileNameWithoutExtension($Executable)
    $TargetFile = "C:\ProgramData\chocolatey\bin\" + $filename + ".exe"
    
    if (![System.IO.File]::Exists($TargetFile))
    {
        Write-Error "File name $TargetFile does not exist"
        Exit
    }


    # $ShortcutFile = [Environment]::GetFolderPath("Desktop") + "\" + $filename + ".lnk"
    $ShortcutFile = [Environment]::GetFolderPath("CommonDesktopDirectory") + "\" + $filename + ".lnk"


    # create shortcut
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Save()
}


foreach ($i in $args)

{

    CreateShortcut $i

}