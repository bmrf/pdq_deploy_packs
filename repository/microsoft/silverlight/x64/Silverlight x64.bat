:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
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
:: Variables :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\logs
set LOGFILE=%COMPUTERNAME%_Microsoft_Silverlight_x64_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=Silverlight v5.1.50918.0 x64.exe
set FLAGS=/q /noupdate

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Install the package from the local folder (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%BINARY%" %FLAGS%
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...
echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL
:: This line disabled the Auto Updater via the registry key
:: Values are: 
:: 0x00000000  - Auto Update
:: 0x00000001  - Prompted Updates (the worst kind...)
:: 0x00000002  - No Updates
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Silverlight" /v UpdateMode /t REG_DWORD /d 0x00000002 /f

:: This line deletes the Start Menu icons
if exist "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Microsoft Silverlight" rmdir /s /q "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Microsoft Silverlight"

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
