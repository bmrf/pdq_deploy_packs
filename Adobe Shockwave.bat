:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
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


:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_Adobe_Shockwave_install.log

:: Package to install. Do not use trailing slashes (\). Do not put quotes around paths or names with spaces.
set BINARY=sw_lic_full_installer.msi
set FLAGS=ALLUSERS=1 /q /norestart

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Remove current versions of Shockwave
wmic product where "name like 'Adobe Shockwave Player%%'" call uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Install the package from the local directory (if all files are in the same place)
msiexec.exe /i "%BINARY%" %FLAGS% >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Disable the auto-updater
regedit /s Adobe_Shockwave_disable_autoupdate.reg >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Disable automatic statistics upload to Adobe
regedit /s Adobe_Shockwave_disable_stats_collection.reg >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the annoying Acrobat tray icon
if exist "%ProgramFiles(x86)%\Adobe\Acrobat 7.0\Distillr\acrotray.exe" (
	taskkill /im "acrotray.exe"
	del /f /q "%ProgramFiles(x86)%\Adobe\Acrobat 7.0\Distillr\acrotray.exe"
	)

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%