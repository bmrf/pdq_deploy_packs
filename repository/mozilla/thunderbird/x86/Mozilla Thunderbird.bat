:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.0
set SCRIPT_UPDATED=2015-12-30
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
set BINARY=Mozilla Thunderbird x86.exe
set FLAGS=/INI="%~dp0Thunderbird_settings.ini"

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::

:: Kill Thunderbird first
taskkill.exe /fi "IMAGENAME eq thunderbird*" /f /t
wmic process where name="thunderbird.exe" call terminate

:: Install the package from a local directory (if all files are in the same directory)
"%BINARY%" %FLAGS%

:: The first command copies the first of two custom preferences files, which is the default new user settings file.
:: The second command copies the second of two custom preferences files, which is the computer-wide settings file.
:: Neither of these contain any settings, they simply redirect Thunderbird to use our settings file on the server. 

:: 32-bit version
if exist "%programfiles%\Mozilla Thunderbird\" copy /Y "%~dp0thunderbird-custom-settings.js" "%programfiles%\Mozilla Thunderbird\"
if exist "%programfiles%\Mozilla Thunderbird\" copy /Y "%~dp0thunderbird-custom-user-settings.js" "%programfiles%\Mozilla Thunderbird\defaults\pref"

:: 64-bit version
if exist "%ProgramFiles(x86)%\Mozilla Thunderbird\" copy /Y "%~dp0thunderbird-custom-settings.js" "%ProgramFiles(x86)%\Mozilla Thunderbird\"
if exist "%ProgramFiles(x86)%\Mozilla Thunderbird\" copy /Y "%~dp0thunderbird-custom-user-settings.js" "%ProgramFiles(x86)%\Mozilla Thunderbird\defaults\pref"

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
