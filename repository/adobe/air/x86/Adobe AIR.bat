:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: Version:       1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.0
set SCRIPT_UPDATED=2015-12-30
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
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_Adobe_AIR_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY_VERSION=
set FLAGS=-silent -eulaAccepted

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Install the package from the local folder (if all files are in the same directory)
"AdobeAIRInstaller.exe" %FLAGS% >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Disable Adobe Updater via registry
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Adobe\Acrobat Reader\11.0\FeatureLockDown" /v bUpdater /t REG_DWORD /d 00000000 /f >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Stop the Adobe Acrobat Update Service
net stop AdobeARMservice >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Disable the Adobe Acrobat Update Service
:: sc config AdobeARMservice start= disabled

:: Delete the Adobe Acrobat Update Service
sc delete AdobeARMservice >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the scheduled task that Adobe installs against our wishes
del /F /S /Q C:\windows\tasks\Adobe*.job >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the Speed Launcher startup task
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup\Adobe Acrobat Speed Launcher.lnk" del /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup\Adobe Acrobat Speed Launcher.lnk"

:: Delete the obnoxious Acrotray exe
taskkill /im "acrotray.exe" >> "%LOGPATH%\%LOGFILE%" 2>NUL
taskkill /im "reader_sl.exe" >> "%LOGPATH%\%LOGFILE%" 2>NUL
taskkill /im "acrobat_sl.exe" >> "%LOGPATH%\%LOGFILE%" 2>NUL
pushd "%ProgramFiles(x86)%\Adobe"
del /f /s /q acrotray.exe >> "%LOGPATH%\%LOGFILE%" 2>NUL
del /f /s /q *_sl.exe >> "%LOGPATH%\%LOGFILE%" 2>NUL
popd

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
