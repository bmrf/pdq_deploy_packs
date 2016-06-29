:: Purpose:       Installs all .cer PKI certificate files in the current directory to the LocalMachine root certificate store
:: Requirements:  1. certmgr.exe from Microsoft (included in Software Development Kit) // MD5 hash of the exe is: 5D077A0CDD077C014EEDB768FEB249BA
::                2. forfiles.exe from Microsoft (included in Win7 and up)
::                3. .cer files to import placed in the same directory as this script and certmgr.exe
::                ! All of these items (certmgr.exe, forfiles.exe, .cer files) must be in the same directory as this script OR in the system PATH
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: Version:       1.0.0   Initial write


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
:: Set your paths here. No trailing slashes (\) in directory paths
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_PKI_certificate_installation.log
:: Max log file size allowed in bytes before rotation and archive. 1048576 bytes is one megabyte
set LOG_MAX_SIZE=2097152


:::::::::::::::::::::::
:: LOG FILE HANDLING ::
:::::::::::::::::::::::
:: Make the logfile if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%
if not exist %LOGPATH%\%LOGFILE% echo. > %LOGPATH%\%LOGFILE%

:: Check log size. If it's less than our max, then jump to the cleanup section
for %%R in (%LOGPATH%\%LOGFILE%) do IF %%~zR LSS %LOG_MAX_SIZE% goto required_files_check

:: If the log was too big, go ahead and rotate it.
pushd %LOGPATH%
del %LOGFILE%.ancient 2>NUL
rename %LOGFILE%.oldest %LOGFILE%.ancient 2>NUL
rename %LOGFILE%.older %LOGFILE%.oldest 2>NUL
rename %LOGFILE%.old %LOGFILE%.older 2>NUL
rename %LOGFILE% %LOGFILE%.old 2>NUL
popd


::::::::::::::::::::::::::
:: REQUIRED FILES CHECK ::
::::::::::::::::::::::::::
:required_files_check
:: Test if we're missing certmgr.exe (the program that does the work)
if not exist certmgr.exe (
		color 0c
		echo.
		echo  ERROR:
		echo.
		echo  Cannot find certmgr.exe. Place it in the
		echo  same directory as this script to continue.
		echo.
		echo %CUR_DATE% %TIME% ! ERROR: Couldn't find certmgr.exe. Quitting.>> %LOGPATH%\%LOGFILE%
		exit /b 1
		)
		
if not exist %SystemRoot%\system32\forfiles.exe (
		color 0c
		echo.
		echo  ERROR:
		echo.
		echo  Cannot find forfils.exe. Place it in 
		echo  %SystemRoot%\system32\ to continue.
		echo.
		echo %CUR_DATE% %TIME% ! ERROR: Couldn't find forfiles.exe. Quitting>> %LOGPATH%\%LOGFILE%
		exit /b 1
		)

:::::::::::::::::::::::
:: Install the certs ::
:::::::::::::::::::::::
echo %CUR_DATE% %TIME%   Installing certificates to localMachine root certificate store...>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Installing certificates to localMachine root certificate store...
:: yes...it's ugly
forfiles /m *.cer /c "cmd /c echo @file & certmgr -c -add "@file" -s root -r localMachine">> %LOGPATH%\%LOGFILE%
forfiles /m *.cer /c "cmd /c echo @file"
echo.
echo %CUR_DATE% %TIME%   Done.>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Done.

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%