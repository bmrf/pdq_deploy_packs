:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.1 * Modify installation flags to use configuration.ini. Thanks to /u/Doraemon2600
::                1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.1
set SCRIPT_UPDATED=2015-03-03
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
set BINARY=Mozilla Firefox x86.exe
set FLAGS=/INI="%CD%\configuration.ini"

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Kill Firefox first
%SystemDrive%\windows\system32\taskkill.exe /F /IM firefox.exe /T 2>NUL
wmic process where name="firefox.exe" call terminate 2>NUL

:: Install the package from the local folder (if all files are in the same directory)
"%BINARY%" %FLAGS%

:: Install 32-bit customisations
if exist "%ProgramFiles%\Mozilla Firefox\" copy /Y "%~dp0override.ini" "%ProgramFiles%\Mozilla Firefox\browser\"
if exist "%ProgramFiles%\Mozilla Firefox\" copy /Y "%~dp0firefox-custom-settings.js" "%ProgramFiles%\Mozilla Firefox\"
if exist "%ProgramFiles%\Mozilla Firefox\" copy /Y "%~dp0local-settings.js" "%ProgramFiles%\Mozilla Firefox\defaults\pref"

:: Install 64-bit customisations
if exist "%ProgramFiles(x86)%\Mozilla Firefox\" copy /Y "%~dp0override.ini" "%ProgramFiles(x86)%\Mozilla Firefox\browser\"
if exist "%ProgramFiles(x86)%\Mozilla Firefox\" copy /Y "%~dp0firefox-custom-settings.js" "%ProgramFiles(x86)%\Mozilla Firefox\"
if exist "%ProgramFiles(x86)%\Mozilla Firefox\" copy /Y "%~dp0local-settings.js" "%ProgramFiles(x86)%\Mozilla Firefox\defaults\pref"

:: Remove Firefox Desktop Icon - Windows XP
if exist "%allusersprofile%\Desktop\Mozilla Firefox.lnk" del "%allusersprofile%\Desktop\Mozilla Firefox.lnk" /S

:: Remove Firefox Desktop Icon - Windows 7
if exist "%public%\Desktop\Mozilla Firefox.lnk" del "%public%\Desktop\Mozilla Firefox.lnk"

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%