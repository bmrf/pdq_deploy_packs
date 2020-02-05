:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.2 + Add proper console and logfile logging
::                1.0.1 + Add uninstallation of previous versions prior to installing. Thanks to github:abulgatz
::                1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.2
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
set LOGFILE=%COMPUTERNAME%_VLC_x86_install.log


:: Package to install. Do not use trailing slashes (\)
set BINARY=VLC v3.0.8 x86.exe
set FLAGS=ALLUSERS=1 /L=1033 /S INSTALLDIR="C:\Program Files (x86)\VLC"

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH

::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::

:: Uninstall old versions first
echo %CUR_DATE% %TIME% Removing previous versions, please wait...
echo %CUR_DATE% %TIME% Removing previous versions, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
if exist "%PROGRAMFILES%\VideoLAN\VLC\uninstall.exe" "%PROGRAMFILES%\VideoLAN\VLC\uninstall.exe" /S
if exist "%PROGRAMFILES(x86)%\VideoLAN\VLC\uninstall.exe" "%PROGRAMFILES(x86)%\VideoLAN\VLC\uninstall.exe" /S
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the package from the local folder (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%BINARY%" %FLAGS%
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Cleanup
echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...
echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL
if exist "%PUBLIC%\Desktop\VLC Media Player.lnk" del /s /q "%PUBLIC%\Desktop\VLC Media Player.lnk"
if exist "%ALLUSERSPROFILE%\Desktop\VLC Media Player.lnk" del /s /q "%ALLUSERSPROFILE%\Desktop\VLC Media Player.lnk"
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
