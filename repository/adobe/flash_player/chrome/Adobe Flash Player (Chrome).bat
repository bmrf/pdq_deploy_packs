:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: Version:       1.0.3 + Add proper console and logfile logging
::                1.0.2 + Add additional commands to remove Adobe scheduled tasks
::                1.0.1 * Expand wildcard mask to catch additional Flash Player Updater scheduled tasks
::                1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.3
set SCRIPT_UPDATED=2020-02-05
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd "%~dp0"


:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\logs
set LOGFILE=%COMPUTERNAME%_Adobe_Flash_Chrome_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=install_flash_player_32_ppapi.msi
set FLAGS=ALLUSERS=1 /q /norestart

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Attempt to kill any running instances first
echo %CUR_DATE% %TIME% Killing any running Chrome-based browsers first, please wait...
echo %CUR_DATE% %TIME% Killing any running Chrome-based browsers first, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
taskkill /f /im chrome.exe /t >> "%LOGPATH%\%LOGFILE%" 2>NUL
taskkill /f /im chromium.exe /t >> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Remove prior versions of the Flash player
echo %CUR_DATE% %TIME% Removing prior versions, please wait...
echo %CUR_DATE% %TIME% Removing prior versions, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
wmic product where "name like 'Adobe Flash Player%%PPAPI'" uninstall /nointeractive
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the package from the local folder (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
msiexec /i "%BINARY%" %FLAGS% >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL



echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...
echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL

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
del /F /Q "%SystemDrive%\Windows\tasks\Adobe Acrobat Update*" >> "%LOGPATH%\%LOGFILE%" 2>NUL
del /F /Q "%SystemDrive%\Windows\tasks\Adobe Flash Player Update*" >> "%LOGPATH%\%LOGFILE%" 2>NUL
del /F /Q "%SystemDrive%\Windows\system32\tasks\Adobe Acrobat Update*" >> "%LOGPATH%\%LOGFILE%" 2>NUL
del /F /Q "%SystemDrive%\Windows\system32\tasks\Adobe Flash Player Update*" >> "%LOGPATH%\%LOGFILE%" 2>NUL
del /F /Q "%SystemDrive%\Windows\system32\tasks\Adobe Flash Player * Notifier" >> "%LOGPATH%\%LOGFILE%" 2>NUL
schtasks.exe /tn "Adobe Flash Player Updater" /delete /f >> "%LOGPATH%\%LOGFILE%" 2>NUL
schtasks.exe /tn "Adobe Flash Player PPAPI Notifier" /delete /f>> "%LOGPATH%\%LOGFILE%" 2>NUL
schtasks.exe /tn "Adobe Flash Player NPAPI Notifier" /delete /f >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the annoying Acrobat tray icon
if exist "%ProgramFiles(x86)%\Adobe\Acrobat 7.0\Distillr\acrotray.exe" (
	taskkill /im "acrotray.exe"
	del /f /q "%ProgramFiles(x86)%\Adobe\Acrobat 7.0\Distillr\acrotray.exe" >> "%LOGPATH%\%LOGFILE%" 2>NUL
)

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%