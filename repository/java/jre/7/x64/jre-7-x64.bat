:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.0
set SCRIPT_UPDATED=2014-09-25
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd "%~dp0"
cls


:::::::::::::::
:: Variables :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=jre7_x64_update.log

:: Package to install. Do not use trailing slashes (\)
set LOCATION=
set BINARY=jre-7u80-windows-x64.exe
set FLAGS=/s /L %LOGPATH%\%LOGFILE% /v"ADDLOCAL=ALL IEXPLORER=1 MOZILLA=1 JAVAUPDATE=0 REBOOT=suppress" /qn

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: This first removes previous versions of the JRE
echo %CUR_DATE% %TIME%   Uninstalling all versions of JRE 7 prior to installation of current version...>> "%LOGPATH%\%LOGFILE%"
wmic product where "IdentifyingNumber like '{26A24AE4-039D-4CA4-87B4-2F___170__FF}'" call uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%"

:: Install the package from a local directory (if all files are in the same directory)
"%BINARY%" %FLAGS%

:: Import the reg file that disables Java auto-updater
regedit /s Tweak_Disable_Java_Auto-Update.reg >> %LOGPATH%\%LOGFILE%

:: Uninstall the Java Auto Updater from Add/Remove Programs because it sometimes sneaks through
wmic product where "name like 'Java Auto Updater'" call uninstall /nointeractive 2>NUL

:: Stop the Java Quickstarter service
net stop JavaQuickStarterService>> "%LOGPATH%\%LOGFILE%"
sc delete JavaQuickStarterService>> "%LOGPATH%\%LOGFILE%"

:: Stop the Java update service
net stop SunJavaUpdateSched>> "%LOGPATH%\%LOGFILE%"
sc delete SunJavaUpdateSched>> "%LOGPATH%\%LOGFILE%"

:: Delete the Java Update directory (normally contains jaureg.exe, jucheck.exe, and jusched.exe)
rmdir /S /Q "%CommonProgramFiles%\Java\Java Update\">> "%LOGPATH%\%LOGFILE%" 2>NUL
rmdir /S /Q "%CommonProgramFiles(x86)%\Java\Java Update\">> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete a bunch of pointless shortcuts Java installs in the All Users Start Menu (sigh...)
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Java Development Kit" rmdir /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Java Development Kit">> "%LOGPATH%\%LOGFILE%"
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Java" rmdir /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Java">> "%LOGPATH%\%LOGFILE%"

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
