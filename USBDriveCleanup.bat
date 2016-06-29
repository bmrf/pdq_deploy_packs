:: Purpose:       Uninstalls non-present USB hubs, USB storage devices and their storage volumes, Disks, CDROMs, Floppies, WPD devices and deletes their registry items
:: Requirements:  Run this script with an admin account
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.0 + Initial write
SETLOCAL
echo off


:::::::::::::::
:: VARIABLES :: -------------- These are the defaults. Change them if you so desire. --------- ::
:::::::::::::::

:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_usb_device_cleanup.log

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


:: --------------------------- Don't edit anything below this line --------------------------- ::



:::::::::::::::::::::
:: PREP AND CHECKS ::
:::::::::::::::::::::
@echo off
set SCRIPT_VERSION=1.0.0
set SCRIPT_UPDATED=2015-01-14
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd "%~dp0"
cls


:::::::::::::
:: Removal ::
:::::::::::::
echo %CUR_DATE% %TIME%  Calling USBDeviceCleanup.exe... > %LOGPATH%\%LOGFILE%
if /i '%PROCESSOR_ARCHITECTURE%'=='AMD64' (
	"DriveCleanup x64.exe" -n >> "%LOGPATH%\%LOGFILE%" 2>&1
) else (
	"DriveCleanup x86.exe" -n >> "%LOGPATH%\%LOGFILE%" 2>&1
)
echo %CUR_DATE% %TIME%  Done.>> %LOGPATH%\%LOGFILE%

REM Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%