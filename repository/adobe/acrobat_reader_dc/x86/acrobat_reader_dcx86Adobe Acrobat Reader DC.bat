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


:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_Adobe_Acrobat_DC_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY_VERSION=15.009.20069
set PATCH_VERSION=15.010.20056
set FLAGS=ALLUSERS=1 /qn /norestart TRANSFORMS="Adobe Acrobat Reader DC v%BINARY_VERSION%_customizations.mst"

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Install base package
msiexec /i "Adobe Acrobat Reader DC v%BINARY_VERSION%.msi" %FLAGS% >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Install patch
msiexec /p "Adobe Acrobat Reader DC v%PATCH_VERSION%_patch.msp" REINSTALL=ALL REINSTALLMODE=omus /qn

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
if exist "%WINDIR%\tasks\Adobe Acrobat Update Task" del /f /q "%WINDIR%\tasks\Adobe Acrobat Update Task" >nul
if exist "%WINDIR%\system32\tasks\Adobe Acrobat Update Task" del /f /q "%WINDIR%\system32\tasks\Adobe Acrobat Update Task" >nul

:: Delete the annoying Acrobat tray icon
if exist "%ProgramFiles(x86)%\Adobe\Acrobat 7.0\Distillr\acrotray.exe" (
	taskkill /im "acrotray.exe"
	del /f /q "%ProgramFiles(x86)%\Adobe\Acrobat 7.0\Distillr\acrotray.exe" >> "%LOGPATH%\%LOGFILE%" 2>NUL
	)

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
