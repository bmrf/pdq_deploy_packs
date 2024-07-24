:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.2 + Add proper console and logfile logging
::                1.0.1 - Remove old versions first. Thanks to github:abulgatz
::                1.0.0 + Initial write

:: Usage:         Run the script and pass one of the following arguments to it:
::                  associate_common  Associate 7-Zip with the common file compression formats 
::                                     (7z,bz2,bzip2,gz,gzip,lzh,lzma,rar,tar,tgz,zip)
::                  associate_all     Associate 7-zip with ALL the file compression formats it supports
::
::                e.g. 7-Zip v9.36 x86.bat associate_all  
::
::                Default is "associate_common" unless told otherwise


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.2
set SCRIPT_UPDATED=2020-02-05
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%


:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=

:: Package to install. Do not use trailing slashes (\)
set LOCATION=
set BINARY=7-Zip v24.07 x86.msi
set FLAGS=ALLUSERS=1 /q /norestart INSTALLDIR="C:\Program Files\7-Zip"

:: Create the log directory if it doesn't exist
if not exist "%LOGPATH%" mkdir "%LOGPATH%"

:: Get into the correct directory
pushd "%~dp0"


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Uninstall other versions of 7-zip
echo %CUR_DATE% %TIME% Removing previous versions, please wait...
echo %CUR_DATE% %TIME% Removing previous versions, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
IF EXIST "%ProgramFiles%\7-Zip\Uninstall.exe" "%ProgramFiles%\7-Zip\Uninstall.exe" /S /V"/qn /norestart"
IF EXIST "%ProgramFiles(x86)%\7-Zip\Uninstall.exe" "%ProgramFiles(x86)%\7-Zip\Uninstall.exe" /S /V"/qn /norestart"
wmic product where "name like '7-Zip%%'" uninstall /nointeractive
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Install the package from the local folder (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%BINARY%" %FLAGS%
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Create file associations
:: Basically we just use a couple FOR loops to iterate through the list since it's prettier than using individual 'assoc' and 'ftype' commands
echo %CUR_DATE% %TIME% Creating file associations...
echo %CUR_DATE% %TIME% Creating file associations...>> "%LOGPATH%\%LOGFILE%" 2>NUL
if '%1'=='associate_all' goto associate_all

:: This section will run no matter what's passed to the installer, UNLESS it's "associate_all" 
:associate_common
for %%i in (7z,bz2,bzip2,gz,gzip,lzh,lzma,rar,tar,tgz,zip) do (
		:: Associations...
		assoc .%%i=7-Zip.%%i
		:: ...and Open With...
		ftype 7-Zip.%%i="C:\Program Files\7-Zip\7zFM.exe" "%%1"
	)
goto finished

:: We do this section if "associate_all" was passed to the installer
:associate_all
for %%i in (001,7z,arj,bz2,bzip2,cab,cpio,deb,dmg,fat,gz,gzip,hfs,iso,lha,lzh,lzma,ntfs,rar,rpm,squashfs,swm,tar,taz,tbz,tbz2,tgz,tpz,txz,vhd,wim,xar,xz,z,zip) do (
		:: Associations...
		assoc .%%i=7-Zip.%%i
		:: ...and Open With...
		ftype 7-Zip.%%i="C:\Program Files\7-Zip\7zFM.exe" "%%1"
	)
goto finished

:finished
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL
