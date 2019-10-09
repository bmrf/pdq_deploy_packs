:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
::@echo off
set SCRIPT_VERSION=1.0.0
set SCRIPT_UPDATED=2019-10-09
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd "%~dp0"
cls



:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes on paths (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=libreoffice_install.log

:: Package to install. Do not use trailing slashes on paths (\)
set BINARY=LibreOffice v6.2.7 x64.msi
set FLAGS=/quiet /norestart /log "%LOGPATH%\%LOGFILE%" REGISTER_NO_MSO_TYPES=1 ISCHECKFORPRODUCTUPDATES=0 REBOOTYESNO=No QUICKSTART=0 ADDLOCAL=ALL VC_REDIST=0 REMOVE=gm_o_Onlineupdate REMOVE=gm_r_ex_Dictionary_Af REMOVE=gm_r_ex_Dictionary_An REMOVE=gm_r_ex_Dictionary_Ar

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Kill running instances first
%SystemDrive%\windows\system32\taskkill.exe /F /IM soffice.bin /T 2>NUL
wmic process where name="soffice.bin" call terminate 2>NUL

:: Remove old version first
wmic product where "name like 'LibreOffice%%'" call uninstall /nointeractive

:: Install the package from the local folder (if all files are in the same directory)
msiexec /i "%BINARY%" %FLAGS%

:: Remove desktop icons
if exist "%allusersprofile%\Desktop\LibreOffice*lnk" del "%allusersprofile%\Desktop\LibreOffice*lnk" /S 2>NUL
if exist "%PUBLIC%\Desktop\LibreOffice*lnk" del "%PUBLIC%\Desktop\LibreOffice*lnk" /S 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
