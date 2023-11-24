:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: Version:       1.0.7 + Add proper console and logfile logging
::                1.0.6 + Add deletion of the desktop icon. Thanks to github:abulgatz
::                1.0.5 + Add removal of previous installations prior to running new installation. Thanks to u/devoar999
::                1.0.4 + Add associating PDF files to Acrobat after installation. Thanks to u/dimm0k
::                1.0.3 + Add killing of Chrome Acrobat plugin registry entry
::                1.0.2 + Add killing of additional Updater registry keys
::                1.0.1 + Add killing of additional Task Scheduler job
::                      + Add killing of Adobe ARM directory
::                1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.7
set SCRIPT_UPDATED=2019-10-16
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
set LOGFILE=%COMPUTERNAME%_Adobe_Acrobat_DC_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY_VERSION=15.007.20033
set PATCH_VERSION=23.006.20380
set FLAGS=ALLUSERS=1 /qn /norestart TRANSFORMS="customizations.mst"

:: Create the log directory if it doesn't exist
if not exist "%LOGPATH%" mkdir "%LOGPATH%"


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Remove prior package
echo %CUR_DATE% %TIME% Removing previous versions, please wait...
echo %CUR_DATE% %TIME% Removing previous versions, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
%WMIC% product where "name like 'Adobe Acrobat Reader%%'" uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Install base package
echo %CUR_DATE% %TIME% Installing base package...
echo %CUR_DATE% %TIME% Installing base package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
msiexec /i "Adobe Acrobat Reader DC v%BINARY_VERSION%.msi" %FLAGS% >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Install patch
echo %CUR_DATE% %TIME% Installing updates...
echo %CUR_DATE% %TIME% Installing updates...>> "%LOGPATH%\%LOGFILE%" 2>NUL
msiexec /p "Adobe Acrobat Reader DC v%PATCH_VERSION%_patch.msp" REINSTALL=ALL REINSTALLMODE=omus /qn >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Disable Adobe Updater via registry; both methods
echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...
echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Adobe\Acrobat Reader\11.0\FeatureLockDown" /v bUpdater /t REG_DWORD /d 00000000 /f >> "%LOGPATH%\%LOGFILE%" 2>NUL
%SystemRoot%\System32\reg.exe delete "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" /v "Adobe ARM" /f >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the Adobe Acrobat Update Service
net stop AdobeARMservice >> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete AdobeARMservice >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the Adobe Acrobat Update Service (older version)
net stop armsvc >> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete armsvc >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the Adobe Flash Player Update Service which the Acrobat installer inexplicably loads
net stop AdobeFlashPlayerUpdateSvc >> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete AdobeFlashPlayerUpdateSvc >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the annoying Scheduler update jobs Adobe installs against our wishes
if exist "%WINDIR%\tasks\Adobe Acrobat Update Task" del /f /q "%WINDIR%\tasks\Adobe Acrobat Update Task" >> "%LOGPATH%\%LOGFILE%" 2>NUL
if exist "%WINDIR%\system32\tasks\Adobe Acrobat Update Task" del /f /q "%WINDIR%\system32\tasks\Adobe Acrobat Update Task" >> "%LOGPATH%\%LOGFILE%" 2>NUL
schtasks /delete /tn "Adobe Acrobat Update Task" /f >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the stupid ARM updater Adobe installs even when we say not to install it
if exist "%ProgramFiles(x86)%\common files\adobe\arm" rmdir /s /q "%ProgramFiles(x86)%\common files\adobe\arm"
if exist "%ProgramFiles%\common files\adobe\arm" rmdir /s /q "%ProgramFiles%\common files\adobe\arm"

:: Delete the annoying Acrobat tray icon
if exist "%ProgramFiles(x86)%\Adobe\Acrobat 7.0\Distillr\acrotray.exe" (
	taskkill /im "acrotray.exe"
	del /f /q "%ProgramFiles(x86)%\Adobe\Acrobat 7.0\Distillr\acrotray.exe" >> "%LOGPATH%\%LOGFILE%" 2>NUL
)

:: Delete the desktop icon
if exist "%PUBLIC%\Desktop\Acrobat Reader DC.lnk" del /f "%PUBLIC%\Desktop\Acrobat Reader DC.lnk"

:: Delete the stupid Chrome plugin Adobe loads without our consent
reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Google\Chrome\Extensions\efaidnbmnnnibpcajpcglclefindmkaj /f >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Associate PDF files to Acrobat
"%ProgramFiles(x86)%\Adobe\Acrobat Reader DC\Reader\ADelRCP.exe"

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
