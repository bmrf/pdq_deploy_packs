:: Purpose:       Silently installs Google Chrome Enterprise and disables auto-update and telemetry collection
:: Requirements:  1. Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       
::                1.0.9 - Remove WMIC task kill and uninstall commands as they're unneeded and slow down the script
::                1.0.8 + Add additional registry entires to further disable GoogleUpdate. Thanks to jasonbergner@silentinstallhq.com
::                1.0.7 * Improve removal of GoogleUpdate tasks in task scheduler
::                1.0.6 * Improve removal of GoogleUpdate tasks in task scheduler
::                1.0.5 + Add removal of GoogleChromeElevationService
::                1.0.4 + Add Remove Software Reporter tool. Thanks to u/pushpak359
::                      + Add proper console and logfile logging
::                1.0.3 + Add removal of any pre-existing Chrome installations prior to installing
::                1.0.2 + Add deletion of additional Google Update scheduled tasks
::                1.0.1 * Add command line argument to preserve shortcuts, default to False
::                1.0.0 + Initial write
@echo off


:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\logs
set LOGFILE=%COMPUTERNAME%_Google_Chrome_x86_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=googlechromestandaloneenterprise x86.msi
set FLAGS=ALLUSERS=1 /q /norestart

:: Create the log directory if it doesn't exist
if not exist "%LOGPATH%" mkdir "%LOGPATH%"


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.9
set SCRIPT_UPDATED=2023-11-21
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

:: Check for command-line argument
set PRESERVE_SHORTCUTS=no
for %%i in (%*) do ( if /i %%i==--preserve-shortcuts set PRESERVE_SHORTCUTS=yes )

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd "%~dp0"
cls


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Kill any running instances of Chrome before installing. This is to avoid the UAC popup for Google Update which occurs if you push the installation while Chrome is running in a user session
echo %CUR_DATE% %TIME% Killing any running Chrome-based browsers, please wait...
echo %CUR_DATE% %TIME% Killing any running Chrome-based browsers, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
%SystemDrive%\windows\system32\taskkill.exe /F /IM chrome.exe /T  >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%"  >> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Uninstall existing versions of Chrome
:: Disabled for now as modern versions of Chrome don't require removal before updating
:: echo %CUR_DATE% %TIME% Removing previous versions, please wait...
:: echo %CUR_DATE% %TIME% Removing previous versions, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
:: wmic product where "name like 'Google Chrome'" call uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%" 2>NUL
:: echo %CUR_DATE% %TIME% Done.
:: echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install package from local directory (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
msiexec.exe /i "%BINARY%" %FLAGS% >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...
echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Import the reg file that disables Chrome auto-updater
regedit /s Tweak_Disable_Chrome_Auto-Update.reg

:: Delete auto-update tasks that Google installs
del /f /q %WinDir%\Tasks\GoogleUpdate* >> "%LOGPATH%\%LOGFILE%" 2>NUL
del /f /q %WinDir%\System32\Tasks\GoogleUpdate* >> "%LOGPATH%\%LOGFILE%" 2>NUL
del /f /q %WinDir%\System32\Tasks_Migrated\GoogleUpdate* >> "%LOGPATH%\%LOGFILE%" 2>NUL
for /f "tokens=2 delims=\" %%i in ('schtasks /query /fo:list ^| findstr ^^GoogleUpdate') do schtasks /Delete /TN %%i /F >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Disable, then delete Google Update services
net stop gupdatem >> "%LOGPATH%\%LOGFILE%" 2>NUL
net stop gupdate >> "%LOGPATH%\%LOGFILE%" 2>NUL
net stop GoogleChromeElevationService >> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete gupdatem >> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete gupdate >> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete GoogleChromeElevationService >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Additional Google Update registry entries to disable auto-updates
reg add "HKLM\SOFTWARE\Policies\Google\Update" /v UpdateDefault /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Google\Update" /v DisableAutoUpdateChecksCheckboxValue /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Google\Update" /v AutoUpdateCheckPeriodMinutes /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Wow6432Node\Google\Update" /v UpdateDefault /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Wow6432Node\Google\Update" /v DisableAutoUpdateChecksCheckboxValue /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Wow6432Node\Google\Update" /v AutoUpdateCheckPeriodMinutes /t REG_DWORD /d 0 /f

:: Remove Google Update directory
if exist "%ProgramFiles(x86)%\Google\Update" rmdir /s /q "%ProgramFiles(x86)%\Google\Update" >> "%LOGPATH%\%LOGFILE%" 2>NUL
if exist "%ProgramFiles%\Google\Update" rmdir /s /q "%ProgramFiles%\Google\Update" >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Remove Software Reporter tool
if exist "%localappdata%\google\chrome\User Data\SwReporter\" rmdir /s /q "%localappdata%\google\chrome\User Data\SwReporter\" >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Remove desktop icons
if %PRESERVE_SHORTCUTS%==no (
	:: Windows XP
	if exist "%allusersprofile%\Desktop\Google Chrome.lnk" del "%allusersprofile%\Desktop\Google Chrome.lnk" /S >> "%LOGPATH%\%LOGFILE%" 2>NUL
	:: Windows 7
	if exist "%public%\Desktop\Google Chrome.lnk" del "%public%\Desktop\Google Chrome.lnk" >> "%LOGPATH%\%LOGFILE%" 2>NUL
)

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. Isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
