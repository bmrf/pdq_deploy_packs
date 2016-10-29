:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.0
set SCRIPT_UPDATED=2015-04-15
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
set LOGFILE=jdk8_i586_update.log

:: Package to install. Do not use trailing slashes (\)
set LOCATION=
set BINARY=jdk-8u112-windows-i586.exe
set FLAGS=/s /l %LOGPATH%\%LOGFILE% ADDLOCAL="ToolsFeature"

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Remove previous versions of the JDK, series 8. The first two digits are the architecture (32 or 64) and the two underscores are WMI wildcards for single characters.
:: This part of the GUID contains the update number of the JDK (e.g. Update 5 is 05). This way we catch all versions of JRE8 on the architecture we want, but DON'T 
:: catch anything else.
wmic product where "IdentifyingNumber like '{32A3A4F4-B792-11D6-A78A-00B0D0180__0}'" call uninstall /nointeractive>> "%LOGPATH%\%LOGFILE%" 2>NUL
:: This also works, but I prefer to use GUID's rather than product names since Sun sometimes changes the "friendly name" of Java in Add/Remove programs
::wmic product where "name like 'Java SE Development Kit 8 Update%%'" uninstall /nointeractive>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Install the package from a local folder (if all files are in the same directory)
"%BINARY%" %FLAGS%

:: Import the reg file that disables Java auto-updater
regedit /s Tweak_Disable_Java_Auto-Update.reg >> %LOGPATH%\%LOGFILE% 2>nul

:: Uninstall the Java Auto Updater from Add/Remove Programs because it sometimes sneaks through
wmic product where "name like 'Java Auto Updater'" call uninstall /nointeractive 2>NUL

:: Stop the Java Quickstarter service
net stop JavaQuickStarterService>> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete JavaQuickStarterService>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Stop the Java update service
net stop SunJavaUpdateSched>> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete SunJavaUpdateSched>> "%LOGPATH%\%LOGFILE%" 2>NUL

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
