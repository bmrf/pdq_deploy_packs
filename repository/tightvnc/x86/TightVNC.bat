:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.1 + Add commands to stop and restart TightVNC server service after installation. Thanks to /u/BadMoodinTheMorning
::                1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.1
set SCRIPT_UPDATED=2017-02-15
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
set BINARY=TightVNC v2.8.27 x86.msi
set FLAGS=/quiet /norestart ADDLOCAL="Server,Viewer"

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: This line uninstalls any prior version
echo %CUR_DATE% %TIME% Removing previous versions, please wait...
echo %CUR_DATE% %TIME% Removing previous versions, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%ProgramFiles%\TightVNC\uninstall.exe" /S >NUL
"%ProgramFiles(x86)%\TightVNC\uninstall.exe" /S >NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Stop any running servers
echo %CUR_DATE% %TIME% Stopping any running servers...
echo %CUR_DATE% %TIME% Stopping any running servers...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%ProgramFiles%\TightVNC\tvnserver.exe" -stop -silent

:: Delay to let it finish
ping 127.0.0.1 -n 2

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the new version
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
msiexec.exe /i "%BINARY%" %FLAGS%
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the new server/listener, and then stops it so we can import the settings file
echo %CUR_DATE% %TIME% Loading configuration files...
echo %CUR_DATE% %TIME% Loading configuration files...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%ProgramFiles%\TightVNC\tvnserver.exe" -stop -silent
"%ProgramFiles%\TightVNC\tvnserver.exe" -install -silent
"%ProgramFiles%\TightVNC\tvnserver.exe" -stop -silent

:: This line imports the new settings
regedit /s "TightVNC settings.reg"
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: This line starts the server back up
echo %CUR_DATE% %TIME% Starting VNC server back up...
echo %CUR_DATE% %TIME% Starting VNC server back up...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%ProgramFiles%\TightVNC\tvnserver.exe" -start -silent >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Additional step to make sure the service is running
net stop tvnserver
net start tvnserver

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:::::::::::::
:: CLEANUP ::
:::::::::::::
echo %CUR_DATE% %TIME% Cleaning up...
echo %CUR_DATE% %TIME% Cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: 64-bit
if exist "%ProgramFiles%\TightVNC\TightVNC Web Site.url" del "%ProgramFiles%\TightVNC\TightVNC Web Site.url"
if exist "%ProgramFiles%\TightVNC\LICENSE.txt" del "%ProgramFiles%\TightVNC\LICENSE.txt"

:: 32-bit
if exist "%ProgramFiles(x86)%\TightVNC\TightVNC Web Site.url" del "%ProgramFiles(x86)%\TightVNC\TightVNC Web Site.url"
if exist "%ProgramFiles(x86)%\TightVNC\LICENSE.txt" del "%ProgramFiles(x86)%\TightVNC\LICENSE.txt"

:: Start menu shortcuts. Comment these lines out if you want to keep start menu shortcuts
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\TightVNC\" rmdir /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\TightVNC\"
if exist "%AllUsersProfile%\Start Menu\Programs\TightVNC\" rmdir /s /q "%AllUsersProfile%\Start Menu\Programs\TightVNC\"

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
