:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: Version:       1.0.2 ! Fix installation hang due to missing /ALLUSERS command. Thanks to github:AJDurant
::                1.0.1 + Add proper console and logfile logging
::                1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.2
set SCRIPT_UPDATED=2021-02-15
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
set LOGFILE=%COMPUTERNAME%_WinSCP_x86_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=WinSCP x86.exe
set FLAGS=/VERYSILENT /ALLUSERS /NOCANDY /NORESTART /MERGETASKS="!desktopicon"

:: Create the log directory if it doesn't exist
if not exist "%LOGPATH%" mkdir "%LOGPATH%"


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: This line kills running instances
echo %CUR_DATE% %TIME% Killing any running WinSCP instances, please wait...
echo %CUR_DATE% %TIME% Killing any running WinSCP instances, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
taskkill /im winscp.exe 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the package from the local folder (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%BINARY%" %FLAGS%
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install customizations, built with CCK2
echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...
echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: These lines delete the desktop icon, if it exists
if exist "%PUBLIC%\Desktop\WinSCP.lnk" del /s /q "%PUBLIC%\Desktop\WinSCP.lnk"
if exist "%ALLUSERSPROFILE%\Desktop\WinSCP.lnk" del /s /q "%ALLUSERSPROFILE%\Desktop\WinSCP.lnk"

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
