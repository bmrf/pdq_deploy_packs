:: Purpose:       Removes all versions of Adobe Flash Player
:: Requirements:  Run this script with an admin account
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.0 + Initial write
SETLOCAL


:::::::::::::::
:: VARIABLES :: -------------- These are the defaults. Change them if you so desire. --------- ::
:::::::::::::::

:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_adobe_flash_player_removal.log

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


:: --------------------------- Don't edit anything below this line --------------------------- ::



:::::::::::::::::::::
:: PREP AND CHECKS ::
:::::::::::::::::::::
@echo off
set SCRIPT_VERSION=1.0.0
set SCRIPT_UPDATED=2014-09-08
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd "%~dp0"
cls

:::::::::::::
:: Removal ::
:::::::::::::
:: Log that we started
echo. > %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%  Beginning removal of Adobe Flash Player (all versions)... >> %LOGPATH%\%LOGFILE%

:: This line first runs the official Adobe package to remove Flash from v11.4.402.265 and older
:: If you don't have this file it's ok, it's not really necessary
echo %CUR_DATE% %TIME%  Running the Adobe uninstaller to remove versions v11.4.402.265 and below first...>> %LOGPATH%\%LOGFILE%
uninstall_flash_player_v11.4.402.265.exe -uninstall >> %LOGPATH%\%LOGFILE%

:: This line uses the official Microsoft WMIC method of uninstalling packages
echo %CUR_DATE% %TIME%  Now using the Microsoft WMIC method to uninstall...>> %LOGPATH%\%LOGFILE%
wmic product where "name like 'Adobe Flash Player%%'" uninstall /nointeractive >> %LOGPATH%\%LOGFILE%

:: Some "just in case" cleanup
echo %CUR_DATE% %TIME%  Now some "just in case" cleanup (deleting Adobe Flash Player Update Service, removing scheduled task, etc)>> %LOGPATH%\%LOGFILE%
net stop AdobeFlashPlayerUpdateSvc >> %LOGPATH%\%LOGFILE%
sc delete AdobeFlashPlayerUpdateSvc >> %LOGPATH%\%LOGFILE%
del /F /Q "%SystemDrive%\Windows\tasks\Adobe Flash Player Updater.job">> %LOGPATH%\%LOGFILE%

echo %CUR_DATE% %TIME%  All versions of Adobe Flash Player have been removed. Recommend rebooting.>> %LOGPATH%\%LOGFILE%

REM Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
