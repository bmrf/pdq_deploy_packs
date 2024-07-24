:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.3 * Add cooldown after installation command to allow msiexec to finish
::                1.0.2 ! Disable previous version uninstallation, as it was causing new installation to silently not succeed
::                1.0.1 + Add proper console and logfile logging
::                1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.3
set SCRIPT_UPDATED=2023-03-04
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
set LOGFILE=%COMPUTERNAME%_LibreOffice_x64_install.log

:: Package to install. Do not use trailing slashes on paths (\)
set BINARY=LibreOffice v24.2.5.msi
set FLAGS=/q /norestart

:: Create the log directory if it doesn't exist
if not exist "%LOGPATH%" mkdir "%LOGPATH%"


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Kill running instances
echo %CUR_DATE% %TIME% Killing any running LibreOffice instances, please wait...
echo %CUR_DATE% %TIME% Killing any running LibreOffice instances, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
%SystemDrive%\windows\system32\taskkill.exe /F /IM soffice.bin /T >> "%LOGPATH%\%LOGFILE%" 2>NUL
wmic process where name="soffice.bin" call terminate >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Remove old version
::echo %CUR_DATE% %TIME% Removing previous versions, please wait...
::echo %CUR_DATE% %TIME% Removing previous versions, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
::wmic product where "name like 'LibreOffice%%'" call uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%" 2>NUL
::echo %CUR_DATE% %TIME% Done.
::echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install main package
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
msiexec /i "%BINARY%" %FLAGS% >> "%LOGPATH%\%LOGFILE%" 2>NUL
ping localhost -n 80 >nul
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...
echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Remove desktop icons
if exist "%allusersprofile%\Desktop\LibreOffice*lnk" del "%allusersprofile%\Desktop\LibreOffice*lnk" /S  >> "%LOGPATH%\%LOGFILE%" 2>NUL
if exist "%allusersprofile%\Desktop\LibreOffice 7.5.lnk" del "%allusersprofile%\Desktop\LibreOffice 7.5.lnk" /S  >> "%LOGPATH%\%LOGFILE%" 2>NUL
if exist "%PUBLIC%\Desktop\LibreOffice*lnk" del "%PUBLIC%\Desktop\LibreOffice*lnk" /S  >> "%LOGPATH%\%LOGFILE%" 2>NUL
if exist "%PUBLIC%\Desktop\LibreOffice 7.5.lnk" del "%PUBLIC%\Desktop\LibreOffice 7.5.lnk" /S  >> "%LOGPATH%\%LOGFILE%" 2>NUL

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
