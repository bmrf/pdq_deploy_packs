:: Purpose:       Installs a package
:: Requirements:  1. Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.4 + Update installer to v7.3.3
::								1.0.3 + Add proper console and logfile logging
::                1.0.2 + Add deletion of additional Google Update scheduled tasks
::                1.0.1 * Add command line argument to preserve shortcuts, default to False
::                1.0.0 + Initial write


:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\logs
set LOGFILE=

:: Package to install. Do not use trailing slashes (\)
set BINARY=Google Earth Pro v7.3.3.exe
set FLAGS=OMAHA=1

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.3
set SCRIPT_UPDATED=2020-02-05
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

:: Check for command-line argument
set PRESERVE_SHORTCUTS=no
for %%i in (%*) do ( if /i %%i==--preserve-shortcuts set PRESERVE_SHORTCUTS=yes )

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd "%~dp0"
cls


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Install package from local directory (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%BINARY%" %FLAGS%
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...
echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL
:: Import the reg file that disables Chrome auto-updater
regedit /s Tweak_Disable_Chrome_Auto-Update.reg

:: Delete auto-update tasks that Google installs
del /f /q %WinDir%\Tasks\GoogleUpdate*
del /f /q %WinDir%\System32\Tasks\GoogleUpdate*
del /f /q %WinDir%\System32\Tasks_Migrated\GoogleUpdate*
schtasks /delete /F /TN "\GoogleUpdateTaskMachineCore"
schtasks /delete /F /TN "\GoogleUpdateTaskMachineUA"

:: Disable, then delete Google Update services
net stop gupdatem 2>NUL
net stop gupdate 2>NUL
sc delete gupdatem 2>NUL
sc delete gupdate 2>NUL

:: Remove Google Update directory
if exist "%ProgramFiles(x86)%\Google\Update" rmdir /s /q "%ProgramFiles(x86)%\Google\Update"
if exist "%ProgramFiles%\Google\Update" rmdir /s /q "%ProgramFiles%\Google\Update"

:: Remove desktop icons
if %PRESERVE_SHORTCUTS%==no (
	:: Windows XP
	if exist "%allusersprofile%\Desktop\Google Earth Pro.lnk" del "%allusersprofile%\Desktop\Google Earth Pro.lnk" /S
	:: Windows 7
	if exist "%public%\Desktop\Google Earth Pro.lnk" del "%public%\Desktop\Google Earth Pro.lnk"
)

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. Isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
