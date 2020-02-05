:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        original TightVNC template by vocatus on reddit.com/r/sysadmin
::                UltraVNC modifications by diggity801 on reddit.com/r/sysadmin
:: History:       1.0.1 + Add proper console and logfile logging
::                1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.1
set SCRIPT_UPDATED=2020-02-05
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
set LOGFILE=%COMPUTERNAME%_UltraVNC_x86_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=UltraVNC v1.2.2.4 x86.exe
set FLAGS=/SP- /verysilent /norestart /loadinf=config.inf ADDLOCAL="Server,Viewer"

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: This line uninstalls any prior version
echo %CUR_DATE% %TIME% Removing previous versions, please wait...
echo %CUR_DATE% %TIME% Removing previous versions, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%ProgramFiles%\UltraVNC\unins000.exe" /verysilent /suppressmsgboxes /norestart >> "%LOGPATH%\%LOGFILE%" 2>NUL
"%ProgramFiles(x86)%\UltraVNC\unins000.exe" /verysilent /suppressmsgboxes /norestart >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delay to let it finish
ping 127.0.0.1 -n 4

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the package from the local folder (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%BINARY%" %FLAGS%
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Copy preconfigured settings, contained in ultravnc.ini, to Program Files (sets password, enables remote input, disables all prompts for incoming connections)
echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...
echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL
copy /Y ultravnc.ini "%ProgramFiles%\UltraVNC\"
copy /Y ultravnc.ini "%ProgramFiles(x86)%\UltraVNC\"
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
