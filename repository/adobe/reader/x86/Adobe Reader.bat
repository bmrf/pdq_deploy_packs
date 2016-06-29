:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: Version:       1.0.1 + Add code to delete another auto-run entry. Thanks to /u/sofakingdead
::                1.0.0 + Import newer version from Tron project (reddit.com/r/TronScript)
::@echo off

:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Package to install. Do not use trailing slashes (\)
set BINARY_VERSION=11.0.10
set PATCH_VERSION=11.0.15
set FLAGS=/sAll /rs /msi /qb- /norestart EULA_ACCEPT=YES REMOVE_PREVIOUS=YES


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
set SCRIPT_VERSION=1.0.1
set SCRIPT_UPDATED=2016-02-26

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd "%~dp0"
cls


:::::::::::::::
:: Variables :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_Adobe_Reader_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=Adobe Reader v11.0.10.exe
set FLAGS=/sAll /rs /msi /qb- /norestart EULA_ACCEPT=YES REMOVE_PREVIOUS=YES

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Remove previous version
wmic product where "name like 'Adobe Reader XI%%'" call uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Install Reader base version
"Adobe Reader v%BINARY_VERSION%.exe" %FLAGS%

:: Install latest patch
msiexec /p "Adobe Reader v11.0.14 patch.msp" REINSTALL=ALL REINSTALLMODE=omus /qn
msiexec /p "Adobe Reader v11.0.16 patch.msp" REINSTALL=ALL REINSTALLMODE=omus /qn

:: Disable Adobe Updater via registry; both methods
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Adobe\Acrobat Reader\11.0\FeatureLockDown" /v bUpdater /t REG_DWORD /d 00000000 /f >> "%LOGPATH%\%LOGFILE%" 2>NUL
%SystemRoot%\System32\reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" /v "Adobe ARM" /f >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the Adobe Acrobat Update Service
net stop AdobeARMservice >> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete AdobeARMservice >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the scheduled task that Adobe installs against our wishes
del /F /Q C:\windows\tasks\Adobe*.job >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete desktop and start icons
if exist "%PUBLIC%\Desktop\Adobe Reader XI.lnk" del /s /q "%PUBLIC%\Desktop\Adobe Reader XI.lnk" >NUL
if exist "%ALLUSERSPROFILE%\Desktop\Adobe Reader XI.lnk" del /s /q "%ALLUSERSPROFILE%\Desktop\Adobe Reader XI.lnk" >NUL

:: Delete the Start Menu icon
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Adobe Reader XI.lnk" del /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Adobe Reader XI.lnk" >NUL

:: Delete the annoying Acrobat tray icon
if exist "%ProgramFiles(x86)%\Adobe\Acrobat 7.0\Distillr\acrotray.exe" (
	taskkill /im "acrotray.exe"
	del /f /q "%ProgramFiles(x86)%\Adobe\Acrobat 7.0\Distillr\acrotray.exe"
	)

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
