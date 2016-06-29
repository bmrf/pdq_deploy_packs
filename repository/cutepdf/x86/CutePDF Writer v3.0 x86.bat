:: Purpose:       Installs a package
:: Requirements:  1. Run this script with Administrator rights
:: Author:        b0park on reddit.com/r/sysadmin
:: History:       1.0.0 + Initial Write

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
set BINARY1=Ghostscript v8.15.exe
set FLAGS1=ALLUSERS=1
set BINARY2=CutePDF Writer v3.0.exe
set FLAGS2=ALLUSERS=1 /verysilent /norestart /no3d

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Install the GhostScript package from the local folder (if all files are in the same directory)
"%BINARY1%" %FLAGS1%

:: Install the CutePDF Writer package from the local folder (if all files are in the same directory)
"%BINARY2%" %FLAGS2%

:: This line removes the Ask Toolbar (if it gets installed)
MsiExec.exe /QN /X {86D4B82A-ABED-442A-BE86-96357B70F4FE}

::This line deletes the unnecessary directory from the Start Menu
rmdir "%ALLUSERSPROFILE%\Start Menu\Programs\CutePDF" /S /Q

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
