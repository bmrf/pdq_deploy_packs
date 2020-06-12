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
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\logs
set LOGFILE=%COMPUTERNAME%_LibreOffice_x64_install.log

:: Package to install. Do not use trailing slashes on paths (\)
set BINARY=LibreOffice v6.4.4.msi
set FLAGS=/quiet /norestart /log "%LOGPATH%\%LOGFILE%" REGISTER_NO_MSO_TYPES=1 ISCHECKFORPRODUCTUPDATES=0 REBOOTYESNO=No QUICKSTART=0 ADDLOCAL=ALL VC_REDIST=0 REMOVE=gm_o_Onlineupdate,gm_r_ex_Dictionary_Af,gm_r_ex_Dictionary_An,gm_r_ex_Dictionary_Ar,gm_r_ex_Dictionary_Be,gm_r_ex_Dictionary_Bg,gm_r_ex_Dictionary_Bn,gm_r_ex_Dictionary_Br,gm_r_ex_Dictionary_Pt_Br,gm_r_ex_Dictionary_Pt_Pt,gm_r_ex_Dictionary_Ca,gm_r_ex_Dictionary_Cs,gm_r_ex_Dictionary_Da,gm_r_ex_Dictionary_Nl,gm_r_ex_Dictionary_Et,gm_r_ex_Dictionary_Gd,gm_r_ex_Dictionary_Gl,gm_r_ex_Dictionary_Gu,gm_r_ex_Dictionary_De,gm_r_ex_Dictionary_He,gm_r_ex_Dictionary_Hi,gm_r_ex_Dictionary_Hu,gm_r_ex_Dictionary_It,gm_r_ex_Dictionary_Lt,gm_r_ex_Dictionary_Lv,gm_r_ex_Dictionary_Ne,gm_r_ex_Dictionary_No,gm_r_ex_Dictionary_Oc,gm_r_ex_Dictionary_Pl,gm_r_ex_Dictionary_Ro,gm_r_ex_Dictionary_Ru,gm_r_ex_Dictionary_Si,gm_r_ex_Dictionary_Sk,gm_r_ex_Dictionary_Sl,gm_r_ex_Dictionary_El,gm_r_ex_Dictionary_Es,gm_r_ex_Dictionary_Sv,gm_r_ex_Dictionary_Te,gm_r_ex_Dictionary_Th,gm_r_ex_Dictionary_Vi,gm_r_ex_Dictionary_Zu,gm_r_ex_Dictionary_Fr

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Kill running instances first
echo %CUR_DATE% %TIME% Killing any running LibreOffice instances, please wait...
echo %CUR_DATE% %TIME% Killing any running LibreOffice instances, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
%SystemDrive%\windows\system32\taskkill.exe /F /IM soffice.bin /T >> "%LOGPATH%\%LOGFILE%" 2>NUL
wmic process where name="soffice.bin" call terminate >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Remove old version first
echo %CUR_DATE% %TIME% Removing previous versions, please wait...
echo %CUR_DATE% %TIME% Removing previous versions, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
wmic product where "name like 'LibreOffice%%'" call uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the package from the local folder (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
msiexec /i "%BINARY%" %FLAGS% >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...
echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Remove desktop icons
if exist "%allusersprofile%\Desktop\LibreOffice*lnk" del "%allusersprofile%\Desktop\LibreOffice*lnk" /S  >> "%LOGPATH%\%LOGFILE%" 2>NUL
if exist "%PUBLIC%\Desktop\LibreOffice*lnk" del "%PUBLIC%\Desktop\LibreOffice*lnk" /S  >> "%LOGPATH%\%LOGFILE%" 2>NUL

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
