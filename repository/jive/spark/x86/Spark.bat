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
set LOGFILE=%COMPUTERNAME%_Spark_x86_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=Spark v2.8.3 x86.exe
set FLAGS=-q

:: Create the log directory if it doesn't exist
if not exist %LOGPATH% mkdir %LOGPATH%


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: Kill any existing instances
echo %CUR_DATE% %TIME% Killing any running Spark instances, please wait...
echo %CUR_DATE% %TIME% Killing any running Spark instances, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
taskkill /im "spark.exe" /f
wmic Path win32_process Where "CommandLine Like '%spark%'" Call Terminate
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the package from a local directory (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%BINARY%" %FLAGS%
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...
echo %CUR_DATE% %TIME% Disabling telemetry and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Remove All Users desktop icon - Windows XP
if exist "%allusersprofile%\Desktop\Spark.lnk" del "%allusersprofile%\Desktop\Spark.lnk" /S

:: Remove All Users desktop icon - Windows 7
if exist "%public%\Desktop\Spark.lnk" del "%public%\Desktop\Spark.lnk"

:: Remove the OTR (Off-the-Record) plugin
if exist "%SystemDrive%\Program Files (x86)\Spark\plugins\otrplug.jar" del /F /Q "%SystemDrive%\Program Files (x86)\Spark\plugins\otrplug.jar"

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
