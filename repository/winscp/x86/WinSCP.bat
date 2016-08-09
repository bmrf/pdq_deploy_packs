:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: Version:       1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.0
set SCRIPT_UPDATED=2015-03-04
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
set BINARY=WinSCP v5.9.0 x86.exe
set FLAGS=/VERYSILENT /NOCANDY /NORESTART /MERGETASKS="!desktopicon"

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: This line kills running instances
taskkill /im winscp.exe 2>NUL

:: Install the new version
"%BINARY%" %FLAGS%


:::::::::::::
:: CLEANUP ::
:::::::::::::
:: These lines delete the desktop icon, if it exists
if exist "%PUBLIC%\Desktop\WinSCP.lnk" del /s /q "%PUBLIC%\Desktop\WinSCP.lnk"
if exist "%ALLUSERSPROFILE%\Desktop\WinSCP.lnk" del /s /q "%ALLUSERSPROFILE%\Desktop\WinSCP.lnk"

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
