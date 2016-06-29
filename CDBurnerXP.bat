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
set BINARY=CDBurnerXP v4.5.7.6139 x64.exe
set FLAGS=/VERYSILENT /LOADINF=settings.cfg

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Install the package from a local directory (if all files are in the same directory)
"%BINARY%" %FLAGS%

REM This disables the online update check.
REM In versions 4.2.5 and above, you have to create an INI 
REM file at the location below with the following contents:
REM   [Setup]
REM   DisableOnlineUpdate=1
if not exist "%ALLUSERSPROFILE%\Canneverbe Limited\CDBurnerXP" mkdir "%ALLUSERSPROFILE%\Canneverbe Limited\CDBurnerXP"
echo [Setup] > "%ALLUSERSPROFILE%\Canneverbe Limited\CDBurnerXP\Application.ini"
echo DisableOnlineUpdate=1 >> "%ALLUSERSPROFILE%\Canneverbe Limited\CDBurnerXP\Application.ini"

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%