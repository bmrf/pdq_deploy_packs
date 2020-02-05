:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: Version:       1.0.1 + Add proper console and logfile logging
::                1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.1
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
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_Apple_iTunes_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=unused
set FLAGS=unused

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Attempt to kill any running instances first
echo %CUR_DATE% %TIME% Killing running instances first, please wait...
echo %CUR_DATE% %TIME% Killing running instances first, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
taskkill /f /im itunes.exe /t >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Remove prior versions
echo %CUR_DATE% %TIME% Removing prior versions, please wait...
echo %CUR_DATE% %TIME% Removing prior versions, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
wmic product where "name like 'Apple Application Support%%'" uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%" 2>NUL
wmic product where "name like 'Apple Mobile Device Support%%'" uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%" 2>NUL
wmic product where "name like 'Bonjour%%'" uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%" 2>NUL
wmic product where "name like '%%iTunes%%'" uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the package from the local folder (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
msiexec /i AppleApplicationSupport64.msi /quiet /norestart >> "%LOGPATH%\%LOGFILE%" 2>NUL
msiexec /i AppleMobileDeviceSupport6464.msi /quiet /norestart >> "%LOGPATH%\%LOGFILE%" 2>NUL
msiexec /i iTunes6464.msi /qn MEDIA_DEFAULTS=1 ALLUSERS=1 REENABLEAUTORUN=0 SCHEDULE_ASUW=0 >> "%LOGPATH%\%LOGFILE%" 2>NUL
msiexec /i Bonjour64.msi /qn >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...
echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete iPod service
net stop "ipod service" >> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete "ipod service" >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete iTunesHelper
taskkill /f /im ituneshelper.exe
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v iTunesHelper /f >> "%LOGPATH%\%LOGFILE%" 2>NUL
reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" /v iTunesHelper /f >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete obnoxious desktop icon
if exist "%PUBLIC%\Desktop\iTunes.lnk" del /f /q "%PUBLIC%\Desktop\iTunes.lnk"

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
