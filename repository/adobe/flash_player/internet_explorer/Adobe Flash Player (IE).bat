:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: Version:       1.0.2 + Add task to delete PPAPI Notifier. Thanks to github:rfg76
::                1.0.1 * Expand wildcard mask to catch additional Flash Player Updater scheduled tasks
::                1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.2
set SCRIPT_UPDATED=2017-06-20
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd "%~dp0"


:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_Adobe_Flash_IE_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=install_flash_player_25_active_x.msi
set FLAGS=ALLUSERS=1 /q /norestart

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: attempt to kill any running instances first
taskkill /f /im iexplore.exe /t >> "%LOGPATH%\%LOGFILE%" 2>NUL
taskkill /f /im iexplorer.exe /t >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Remove prior versions of the Flash player
wmic product where "name like 'Adobe Flash Player%%ActiveX'" uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Install the package from the local folder (if all files are in the same directory)
msiexec /i "%BINARY%" %FLAGS% >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the Adobe Acrobat Update Service
net stop AdobeARMservice >> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete AdobeARMservice >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the Adobe Acrobat Update Service (older version)
net stop armsvc >> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete armsvc >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the Adobe Flash Player Update Service
net stop AdobeFlashPlayerUpdateSvc >> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete AdobeFlashPlayerUpdateSvc >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete scheduled tasks Adobe installs against our wishes
del /F /Q "%SystemDrive%\Windows\tasks\Adobe Flash Player Update*" >> "%LOGPATH%\%LOGFILE%" 2>NUL
del /F /Q "%SystemDrive%\Windows\system32\tasks\Adobe Flash Player Update*" >> "%LOGPATH%\%LOGFILE%" 2>NUL
del /F /Q "%SystemDrive%\Windows\system32\tasks\Adobe Flash Player PPAPI Notifier*" >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the annoying Acrobat tray icon
if exist "%ProgramFiles(x86)%\Adobe\Acrobat 7.0\Distillr\acrotray.exe" (
	taskkill /im "acrotray.exe" >> "%LOGPATH%\%LOGFILE%" 2>NUL
	del /f /q "%ProgramFiles(x86)%\Adobe\Acrobat 7.0\Distillr\acrotray.exe" >> "%LOGPATH%\%LOGFILE%" 2>NUL
)

:: Copy config file, this will overwrite any existing file
if exist "%WinDir%\System32\Macromed\Flash\" (
	copy mms.cfg %WinDir%\System32\Macromed\Flash\mms.cfg /Y >> "%LOGPATH%\%LOGFILE%" 2>NUL
)
if exist "%WinDir%\SysWow64\Macromed\Flash\" (
	copy mms.cfg %WinDir%\SysWow64\Macromed\Flash\mms.cfg /Y >> "%LOGPATH%\%LOGFILE%" 2>NUL
)

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
