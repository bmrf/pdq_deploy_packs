:: Purpose:       Installs a package
:: Requirements:  Run this script with Administrator rights. Use the --preserve-shortcuts CLI switch to prevent the script from deleting Notepad++'s Start Menu shortcuts. Thanks to github:sn3ak
:: Author:        vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
:: History:       1.0.2 + Add proper console and logfile logging
::                1.0.1 + Add --preserve-shortcuts switch and associated PRESERVE_SHORTCUTS variable. Use this to prevent script from deleting Notepad++'s Start Menu shortcuts.
::                1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
@echo off
set SCRIPT_VERSION=1.0.2
set SCRIPT_UPDATED=2020-02-05
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%

:: This is useful if we start from a network share; converts CWD to a drive letter
pushd "%~dp0"
cls

:: Check for command-line argument
set PRESERVE_SHORTCUTS=no
for %%i in (%*) do ( if /i %%i==--preserve-shortcuts set PRESERVE_SHORTCUTS=yes )



:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\logs
set LOGFILE=%COMPUTERNAME%_Notepadpp_x86_install.log

:: Package to install. Do not use trailing slashes (\)
set BINARY=npp.8.6.0.Installer.exe
set FLAGS=/S


:: Create the log directory if it doesn't exist
if not exist "%LOGPATH%" mkdir "%LOGPATH%"


::::::::::::::::::
:: INSTALLATION ::
::::::::::::::::::
:: These lines attempt to kill any running instances first
echo %CUR_DATE% %TIME% Killing any running Notepad++ instances, please wait...
echo %CUR_DATE% %TIME% Killing any running Notepad++ instances, please wait...>> "%LOGPATH%\%LOGFILE%" 2>NUL
taskkill /f /im notepad++.exe /t >> "%LOGPATH%\%LOGFILE%" 2>NUL
wmic process where name="notepad++.exe" call terminate >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL


:: Install the package from a local directory (if all files are in the same directory)
echo %CUR_DATE% %TIME% Installing package...
echo %CUR_DATE% %TIME% Installing package...>> "%LOGPATH%\%LOGFILE%" 2>NUL
"%BINARY%" %FLAGS% >> "%LOGPATH%\%LOGFILE%" 2>NUL
echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL



echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...
echo %CUR_DATE% %TIME% Finishing configuration and cleaning up...>> "%LOGPATH%\%LOGFILE%" 2>NUL
:: Create allowAppDataPlugins.xml file so plugins are installed to %appdata%. Thanks to /u/ObiWanBaloney
if exist "%ProgramFiles%\Notepad++" copy NUL "%ProgramFiles%\Notepad++\allowAppDataPlugins.xml" >> "%LOGPATH%\%LOGFILE%" 2>NUL
if exist "%ProgramFiles(x86)%\Notepad++" copy NUL "%ProgramFiles(x86)%\Notepad++\allowAppDataPlugins.xml" >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the updater plugin
if exist "%SystemDrive%\Program Files (x86)\Notepad++\updater" rmdir /s /q "%SystemDrive%\Program Files (x86)\Notepad++\updater" >> "%LOGPATH%\%LOGFILE%" 2>NUL
if exist "%SystemDrive%\Program Files\Notepad++\updater" rmdir /s /q "%SystemDrive%\Program Files\Notepad++\updater" >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the DSpellCheck plugin
del /f /q "%SystemDrive%\Program Files\Notepad++\plugins\DSpellCheck.dll" >> "%LOGPATH%\%LOGFILE%" 2>NUL
del /f /q "%SystemDrive%\Program Files (x86)\Notepad++\plugins\DSpellCheck.dll" >> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Delete the Start Menu directory
if %PRESERVE_SHORTCUTS%==no (
	if exist "%ALLUSERSPROFILE%\Start Menu\Programs\Notepad++" rmdir /s /q "%ALLUSERSPROFILE%\Start Menu\Programs\Notepad++" >> "%LOGPATH%\%LOGFILE%" 2>NUL
)

echo %CUR_DATE% %TIME% Done.
echo %CUR_DATE% %TIME% Done.>> "%LOGPATH%\%LOGFILE%" 2>NUL

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
