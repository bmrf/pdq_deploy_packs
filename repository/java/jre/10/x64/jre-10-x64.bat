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
:: Variables :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\logs
set LOGFILE=jre10_x64_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=jre-10.0.2-x64.msi
set FLAGS=ALLUSERS=1 /qn /norestart /l %LOGPATH%\%LOGFILE% JU=0 JAVAUPDATE=0 AUTOUPDATECHECK=0 RebootYesNo=No WEB_JAVA_SECURITY_LEVEL=M

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: This first removes previous versions of the JRE
echo %CUR_DATE% %TIME% Removing previous versions, please wait...
echo %CUR_DATE% %TIME% Removing previous versions, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
WMIC product where "IdentifyingNumber like '{DA69628A-2608-5BA9-8749-1EE90CB29D95}'" call uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%"
WMIC product where "IdentifyingNumber like '{2590B9D6-4310-52BC-808E-1A585861A836}'" call uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%"
WMIC product where "name like 'Java 10%%'" uninstall /nointeractive
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the package from a local directory (if all files are in the same directory)
:: Nothing below this line will log correctly, because MSI logs in a different format than the standard "echo >> %logfile%" commands. Haven't had time to find a workaround.
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
msiexec /i "%BINARY%" %FLAGS%
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...
echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: This line kills the Java Update scheduler if it's running
%SystemRoot%\System32\taskkill.exe /f /im jusched.exe>>%LOGPATH%\%LOGFILE% 2>NUL

:: Uninstall the Java Auto Updater from Add/Remove Programs because it sometimes sneaks through
wmic product where "name like 'Java Auto Updater'" call uninstall /nointeractive 2>NUL
wmic product where "IdentifyingNumber like '{4A03706F-666A-4037-7777-5F2748764D10}'" call uninstall /nointeractive >> "%LOGPATH%\%LOGFILE%"

:: These lines disable the Java Auto-Updater keys in the registry
%SystemRoot%\System32\reg.exe DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v SunJavaUpdateSched /f>> "%LOGPATH%\%LOGFILE%" 2>NUL
%SystemRoot%\System32\reg.exe DELETE "HKLM\SOFTWARE\JavaSoft\Java Update" /f>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Stop the Java Quickstarter service
net stop JavaQuickStarterService>> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete JavaQuickStarterService>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Stop the Java update service
net stop SunJavaUpdateSched>> "%LOGPATH%\%LOGFILE%" 2>NUL
sc delete SunJavaUpdateSched>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the Java Update directory (normally contains jaureg.exe, jucheck.exe, and jusched.exe)
rmdir /S /Q "%CommonProgramFiles%\Java\Java Update\">> "%LOGPATH%\%LOGFILE%" 2>NUL
rmdir /S /Q "%CommonProgramFiles(x86)%\Java\Java Update\">> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete a bunch of pointless shortcuts Java installs in the All Users Start Menu (sigh...)
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Java Development Kit" rmdir /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Java Development Kit">> "%LOGPATH%\%LOGFILE%"
if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Java" rmdir /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Java">> "%LOGPATH%\%LOGFILE%"

:: This installs the customization files to set the Java Web Security level to MEDIUM (default in all versions prior to JRE8)
XCOPY deployment.* %WINDIR%\Sun\Java\Deployment /I /Y
XCOPY *.sites %WINDIR%\Sun\Java\Deployment /I /Y

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
