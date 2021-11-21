@ECHO OFF

SET SrcRoot=C:\Forensics\Plugins\autopsy-plugins\Autopsy-Plugins-master
SET TargetRoot=%APPDATA%\autopsy\python_modules\

FOR /D %%A IN ("%SrcRoot%\*") DO (
    MKLINK /D "%TargetRoot%\%%~NA" "%%~A" 2> nul
    )
