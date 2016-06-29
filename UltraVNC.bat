:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        original TightVNC template by vocatus on reddit.com/r/sysadmin
::                UltraVNC modifications by diggity801 on reddit.com/r/sysadmin
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
set BINARY=UltraVNC v1.2.0.9 x86.exe
set FLAGS=/SP- /verysilent /norestart /loadinf=config.inf ADDLOCAL="Server,Viewer"

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: This line uninstalls any prior version
"%ProgramFiles%\UltraVNC\unins000.exe" /verysilent /suppressmsgboxes /norestart >NUL
"%ProgramFiles(x86)%\UltraVNC\unins000.exe" /verysilent /suppressmsgboxes /norestart >NUL

:: Delay to let it finish
ping 127.0.0.1 -n 4

:: Install the new version
"%BINARY%" %FLAGS%

:: Copy preconfigured settings, contained in ultravnc.ini, to Program Files (sets password, enables remote input, disables all prompts for incoming connections)
copy /Y ultravnc.ini "%ProgramFiles%\UltraVNC\"
copy /Y ultravnc.ini "%ProgramFiles(x86)%\UltraVNC\"

:::::::::::::::::::::::::::::::::::::
:: RETURN EXIT CODE TO REMOTE HOST ::
:::::::::::::::::::::::::::::::::::::
:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%