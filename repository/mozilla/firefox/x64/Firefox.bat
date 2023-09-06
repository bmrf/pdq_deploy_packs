:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.4 * Update to support new policies.json Firefox config format
::                1.0.3 + Add proper console and logfile logging
::                1.0.2 + Add additional uninstall commands make sure we fully remove old versions first. Thanks to github:abulgatz
::                1.0.1 * Expand Desktop shortcut deletion mask to sweep all subdirectories under the base user profile directory
::                1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.4
set SCRIPT_UPDATED=2020-06-02
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
set LOGPATH=%SystemDrive%\logs
set LOGFILE=%COMPUTERNAME%_Mozilla_Firefox_x64_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=Mozilla Firefox.exe
set FLAGS=/INI="%CD%\configuration.ini"

:: Create the log directory if it doesn't exist
if not exist "%LOGPATH%" mkdir "%LOGPATH%"


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Kill Firefox
echo %CUR_DATE% %TIME% Killing any running Firefox instances, please wait...
echo %CUR_DATE% %TIME% Killing any running Firefox instances, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
%SystemDrive%\windows\system32\taskkill.exe /F /IM firefox.exe /T 2>NUL
wmic process where name="firefox.exe" call terminate 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Remove old version
echo %CUR_DATE% %TIME% Removing previous versions, please wait...
echo %CUR_DATE% %TIME% Removing previous versions, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
IF EXIST "%ProgramFiles%\Mozilla Firefox\uninstall\helper.exe" "%ProgramFiles%\Mozilla Firefox\uninstall\helper.exe" /S
IF EXIST "%ProgramFiles(x86)%\Mozilla Firefox\uninstall\helper.exe" "%ProgramFiles(x86)%\Mozilla Firefox\uninstall\helper.exe" /S
wmic product where "name like 'Mozille Firefox%%'" call uninstall /nointeractive
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the package from the local folder (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%BINARY%" %FLAGS%
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install customizations (via policies.json)
echo %CUR_DATE% %TIME% Installing policies.json...
echo %CUR_DATE% %TIME% Installing policies.json...>> "%LOGPATH%\%LOGFILE%" 2>NUL

if exist "%ProgramFiles(x86)%\Mozilla Firefox\" (
	mkdir "%ProgramFiles(x86)%\Mozilla Firefox\distribution">> "%LOGPATH%\%LOGFILE%" 2>NUL
	xcopy /s /e /y ".\policies.json" "%ProgramFiles(x86)%\Mozilla Firefox\distribution">> "%LOGPATH%\%LOGFILE%" 2>NUL	
)

if exist "%ProgramFiles%\Mozilla Firefox\" (
	mkdir "%ProgramFiles%\Mozilla Firefox\distribution">> "%LOGPATH%\%LOGFILE%" 2>NUL
	xcopy /s /e /y ".\policies.json" "%ProgramFiles%\Mozilla Firefox\distribution"
)

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Clean up
echo %CUR_DATE% %TIME% Cleaning up...
echo %CUR_DATE% %TIME% Cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Remove desktop icons
REM if exist "%allusersprofile%\Desktop\Mozilla Firefox.lnk" del "%allusersprofile%\Desktop\Mozilla Firefox.lnk" /S
REM if exist "%public%\Desktop\Mozilla Firefox.lnk" del "%public%\Desktop\Mozilla Firefox.lnk"
REM if exist "%SystemDrive%\users\default\Desktop\Mozilla Firefox.lnk" del "%SystemDrive%\users\default\Desktop\Mozilla Firefox.lnk"

:: Lets just amp this up and catch ANYWHERE it might drop a shortcut 
del /f /s "%SystemDrive%\Users\*Firefox.lnk" 2>nul

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
