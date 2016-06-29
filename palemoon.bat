:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.0
set SCRIPT_UPDATED=2014-07-25
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd "%~dp0"
cls


:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=

:: Package to install. Do not use trailing slashes (\)
set LOCATION=
set BINARY=Palemoon x86.exe
set FLAGS=-ms

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%

:: Get into the correct directory
cd "%~dp0"


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Kill Pale Moon
%SystemDrive%\windows\system32\taskkill.exe /F /IM palemoon.exe /T 2>NUL
wmic process where name="palemoon.exe" call terminate 2>NUL

:: Install palemoon
"%BINARY%" %FLAGS%

:: Install 32-bit customisations
if exist "%programfiles%\Pale Moon\" copy /Y "override.ini" "%programfiles%\Pale Moon\browser\"
if exist "%programfiles%\Pale Moon\" copy /Y "Pale-Moon-custom-settings.js" "%programfiles%\Pale Moon\"
if exist "%programfiles%\Pale Moon\" copy /Y "local-settings.js" "%programfiles%\Pale Moon\defaults\pref"

:: Install 64-bit customisations
if exist "%ProgramFiles(x86)%\Pale Moon\" copy /Y "override.ini" "%ProgramFiles(x86)%\Pale Moon\browser"
if exist "%ProgramFiles(x86)%\Pale Moon\" copy /Y "Pale-Moon-custom-settings.js" "%ProgramFiles(x86)%\Pale Moon\"
if exist "%ProgramFiles(x86)%\Pale Moon\" copy /Y "local-settings.js" "%ProgramFiles(x86)%\Pale Moon\defaults\pref"

:: Remove Pale Moon Desktop Icon - Windows XP
if exist "%allusersprofile%\Desktop\Pale Moon.lnk" del "%allusersprofile%\Desktop\Pale Moon.lnk"

:: Remove Pale Moon Desktop Icon - Windows 7
if exist "%public%\Desktop\Pale Moon.lnk" del "%public%\Desktop\Pale Moon.lnk"

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%