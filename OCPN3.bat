:: Purpose:       Wrapper for delprof2.exe from Helge Klein
::                Deletes cached user profiles on the target machine that haven't been logged into in the specified number of days.
::                Latest version of this script can always be found here:
::                http://www.reddit.com/r/usefulscripts/comments/22oxf6/batch_orbital_cached_profile_nuker_delete_old/
:: Requirements:  1. Administrator rights on whatever machine you're running against
::                2. Delprof2.exe. Tested with v1.6.0.0 ( MD5: FDC4366BE4D0E0D02C35B394CA59DD14 )
::                3. psexec.exe from sysinternals (now Microsoft), to remotely start the Remote Registry service if it isn't running
::                4. [OPTIONAL] names.txt -- A list of computers to run against, one DNS name or IP address per line. 
::
::                These files may be in any of the following locations:
::                    a) the directory you run the script from
::                    b) in the system PATH variable
::                    c) c:\windows\system32\
::
:: History:       3.2.2 * Overhauled Date/Time conversion so we can handle ALL versions of Windows using ANY local date-time format
::                3.2.1 * Added /ntuserini flag to DelProf2 to work around incorrect detection of in-use profiles on Windows 7 x64 domain machines
::                3.2   + Added "auto" flag. Can now pass hostname, days, and the word "auto" to run without prompts. Useful for mass deployment or PDQ/SCCM/WPKG packages
::                      * Expanded checks for psexec to look in both Program Files directories on 64-bit Windows
::                      * Changed Psexec flags to include -accepteula as well as redirect error output to NUL (2>NUL);
::                        this suppresses the obnoxious Psexec banner that appears every time it runs
::                      - Removed many GOTO statements and replaced with if/while statements
::                3.1b  * Reworked CUR_DATE variable to handle more than one Date/Time format
::                        Can now handle all Windows date formats
::                      * Comment cleanup
::                      * Reduced cooldown between run and log upload
::                3.1a  + Added timestamp to log file before and after doing a single-host run
::                3.1   + Added "SCRIPT_UPDATED" variable to note when the script was last updated
::                      + Added "CUR_DATE" variable to be consistent with other scripts
::                3.0   + Branched off OCPN2 v2.7
::                      / Changed to use DelProf2.exe instead of the DeleteProfiles.vbs script (more reliable)
::                      + Added standard commenting blocks to Variables and various other sections
::                      / Log file collection & compilation changed. Logs are now:
::                          1. Collected locally in a temp directory
::                          2. Uploaded to their respective hosts after completion (so there's a local record that the script ran)
::                          3. Compiled into a single master log on the initiating system
::                2.7   * Cleaned up required files check into proper IF statements
::                2.6   + Added function to clear errorlevel in mass upload loop
::                2.5   * Logging function massively improved and debugged
::                      * Many glitches and failure conditions fixed
::                2.4   - skipped
::                2.3   * Some code cleanup and logging improvement
::                2.2   + Added verbose flag to run-once portion
::                      + Added ping -n 2 >NUL to the log collector loop, to prevent tripping McAfee's DoS detector
::                      * Improved log file rotation section significantly
::                2.1   + Added log rotation code to auto-archive and age out log files
::                      + Added "PAYLOAD" variable to represent the DeleteProfiles.vbs script
::                      + Added check for existence of the .vbs script
::                2.0   * Complete re-write, meant as a replacement for OCPN.bat
::                      - Now uses DeleteProfiles.vbs from Joe Shonk for more accuracy and compatibility
::                      - Fetches log files from remote computer after operation
::                      - Logs which registry keys deleted and why they were deleted
::                      - Can be invoked by specifying either a host or 'all' as the first argument, followed by 
::                        the number of days. Example: OCPN2.bat all 30 

:: Use:           Run the script one of these ways:
::                      a. Directly. You'll be prompted for target and age in days. You'll be given a chance to
::                         see what will be deleted before it runs.
::                           example:  ocpn3.bat
::                      b. Pass hostname or IP as first argument. You'll be prompted for age in days before
::                         running and given a chance to see what will be deleted before it runs.
::                           example:  ocpn3.bat ComputerName
::                      c. Pass a hostname AND days as the first two arguments, and you'll be given a chance to
::                         see what will be deleted before it runs.
::                           example:  ocpn3.bat ComputerName 30
::                      d. (MASS BATCH MODE) pass in this order: hostname, days, auto to execute without prompts.
::                         Useful for mass deployment or use in a package (PDQ/SCCM/WPKG/etc). 
::                           example:  ocpn3.bat ComputerName 30 auto
::                      e. Optionally, you may place a list of hostnames in the NAMES_FILE (specify the name of 
::                         this file below in the VARIABLES section) and run the script against all systems specified
::                         in the NAMES_FILE. If you pass "all" and a number of days, "auto" is assumed (no prompts).
::                           examples:  ocpn3.bat all
::                                      ocpn3.bat all 30


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
setlocal enabledelayedexpansion
@echo off
set SCRIPT_VERSION=3.2.2
set SCRIPT_UPDATED=2014-07-23
:: Get the date into ISO 8601 standard date format (yyyy-mm-dd) so we can use it
FOR /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') DO set DTS=%%a
set CUR_DATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%
set TARGET=%1
set DAYS=%2
set AUTO=%3
set RUN_ONCE=false
title Orbital Cached Profile Nuker v%SCRIPT_VERSION%
cls


:::::::::::::::
:: VARIABLES :: -- Set these to your desired values
:::::::::::::::
:: Rules for variables:
::  * NO quotes!                       (bad:  "c:\directory\path"       )
::  * NO trailing slashes on the path! (bad:   c:\directory\            )
::  * Spaces are okay                  (okay:  c:\my folder\with spaces )
::  * Network paths are okay           (okay:  \\server\share name      )
::                                     (       \\172.16.1.5\share name  )
:: Names file is a list of systems you want to act against. One system IP or hostname per line, list can contain both systems and hostnames
set NAMES_FILE=names_workstations.txt

:: Specify profiles to exclude from checking. You can use the wildcards '*' and '?'
set EXCLUDE_PROFILES=admin.nti

:: Timeout in seconds before giving up on a host and moving on to the next one
set CONNECTION_TIMEOUT=3

:: Logging information
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_OCPN3.log


::::::::::::::::::::::::::
:: REQUIRED FILES CHECK ::
::::::::::::::::::::::::::
:: Test if we're missing DelProf2.exe (the program that does the work)
if not exist Delprof2.exe (
		color 0c
		echo.
		echo  ERROR:
		echo.
		echo  Cannot find Delprof2.exe. Place Delprof2.exe in 
		echo  the same directory as this script to continue.
		echo.
		pause
		exit /B 1
		)

:: Test if we're missing PsExec
IF EXIST psexec.exe goto run_test
IF EXIST "%ProgramFiles%\SysInternalsSuite\psexec.exe" goto run_test
IF EXIST "%ProgramFiles(x86)%\SysInternalsSuite\psexec.exe" goto run_test
IF EXIST %WINDIR%\system32\psexec.exe goto run_test
color 0c
	echo.
	echo  ERROR:
	echo.
	echo  Cannot find PsExec.exe. Place PsExec.exe in 
	echo  the same directory as this script to continue.
	echo.
pause
exit /B 1

:: Test if we're doing a run-once
:run_test
IF "%TARGET%"=="all" goto multiple_pc_run_once
IF NOT "%TARGET%"=="" goto single_pc_run_once
::cls


::::::::::::::::::::
:: WELCOME SCREEN ::
::::::::::::::::::::
:welcome
set DAYS=60
echo.
echo  *********************************************************
echo  *                                                       *
echo  *         ORBITAL CACHED PROFILE NUKER (OCPN) v%SCRIPT_VERSION%      *
echo  * ----------------------------------------------------- *
echo  * Nuke them from orbit. It's the only way to be sure.   *
echo  *                                                       *
echo  * Windows XP/Vista/7/8 caches user profiles at login,   *
echo  * which use a lot of space over time. This script       *
echo  * deletes profiles which haven't been logged into in a  *
echo  * a specified period.                                   *
echo  *                                                       *
echo  * Run this script with NETWORK ADMIN rights. Local      *
echo  * admin rights aren't enough.                           *
echo  *                                                       *
echo  *********************************************************
echo.
echo  Current settings
echo     Names file:         %NAMES_FILE%
echo     Connection timeout: %CONNECTION_TIMEOUT% seconds
echo     Profile exclusions: %EXCLUDE_PROFILES%
echo     Log location:       %LOGPATH%
echo.
echo   Edit this script with a text editor to customize these options.
echo.
:single_pc_loop
title OCPN3 v%SCRIPT_VERSION%
echo.
set /p TARGET=Enter IP, hostname or 'all': 
	if %TARGET%==exit goto end
set /P DAYS=  Nuke profiles older than how many days? [%DAYS%]: 
	if %DAYS%==exit goto end
	if %TARGET%==all color && goto multiple_pc_go

color
set RUN_ONCE=false
goto single_pc_go


:: ===================================================== ::
::            START OF SINGLE TARGET SECTION             ::
:: ===================================================== ::

:::::::::::::::::::::::::
:: COMMAND-LINE CHECKS ::
:::::::::::::::::::::::::
:single_pc_run_once
set RUN_ONCE=true

:: If "auto" was passed, go ahead and run the auto-nuke without prompting
if "%AUTO%"=="auto" (
	echo %CUR_DATE% %TIME%   OCPN3 launched in batch mode against target '%TARGET%' for profiles older than %DAYS% days.>>%LOGPATH%\%TARGET%_OCPN3.log
	delprof2 /U /I /C:\\%TARGET% /D:%DAYS% /ED:%EXCLUDE_PROFILES% /ntuserini>> %LOGPATH%\%TARGET%_OCPN3.log
	echo %CUR_DATE% %TIME%   Done.>>%LOGPATH%\%TARGET%_OCPN3.log
	exit /B 0
	)

:: If "days" wasn't set, go ahead and prompt user for it
if "%DAYS%"=="" (
	set DAYS=30
	echo.
	echo  Target: %TARGET%
	echo.
	set /P DAYS=  Nuke profiles older than how many days? [!DAYS!]: 
	if "!DAYS!"=="exit" exit /B 0
	)

:::::::::::::::
:: EXECUTION ::
:::::::::::::::
:single_pc_go
title OCPN v%SCRIPT_VERSION%: Nuking profiles, please wait...
echo.
echo  ===========================================
echo  =========== Beginning OCPN3 run ===========
echo  ===========================================
echo.
echo  == Prepping target...                    ==
:: We need to make sure the RemoteRegistry service is running, otherwise delprof2 will fail.
ping -n 1 %TARGET% 2>NUL
psexec -accepteula -n %CONNECTION_TIMEOUT% \\%TARGET% cmd /c (sc config RemoteRegistry start= auto ^& net start RemoteRegistry)>> %LOGPATH%\%LOGFILE%
echo  == Done.                                 ==
echo.

:: Only run prompt if we're not doing an automatic (batch) run
echo  == Enumerating candidate accounts...     ==
echo.
:: Flags: /u unattended, /i ignore errors, /c:\\ run on the specified remote system, /d: profiles older than x days
delprof2 /U /I /C:\\%TARGET% /D:%DAYS% /ED:%EXCLUDE_PROFILES% /ntuserini /L
echo.
echo  == Done.                                 ==
echo.

:: Give us one last chance to back out
echo  ! Read the above list of accounts carefully, and note which WILL and WILL NOT be deleted.
echo    Okay to continue?
echo.
echo    YOU CANNOT UNDO THIS ACTION!
echo.
set CHOICE=n
set /P CHOICE=Proceed? [y/N]: 
	if '%CHOICE%'=='exit' goto end
	if '%CHOICE%'=='n' goto welcome
echo.
echo  == Nuking accounts...                    ==
echo.
echo %CUR_DATE% %TIME%         Starting run.>> %LOGPATH%\%TARGET%_OCPN3.log
delprof2 /U /I /C:\\%TARGET% /D:%DAYS% /ED:%EXCLUDE_PROFILES% /ntuserini>> %LOGPATH%\%TARGET%_OCPN3.log
echo %CUR_DATE% %TIME%         Finished run.>> %LOGPATH%\%TARGET%_OCPN3.log
echo  == Done.                                 ==
echo.
echo  == Uploading log to target...            ==
:: Copy the log file to the target and to our master log, then delete the temp one
copy %LOGPATH%\%TARGET%_OCPN3.log \\%TARGET%\C$\Logs\%TARGET%_OCPN3.log /Y >NUL
type %LOGPATH%\%TARGET%_OCPN3.log >> %LOGPATH%\OCPN3_master.log
del /q %LOGPATH%\%TARGET%_OCPN3.log >NUL
if %ERRORLEVEL%==0 echo. && echo  == Done.                                 ==
if %ERRORLEVEL%==1 echo. && echo  == Failed.                               ==

::::::::::::
:: REPORT ::
::::::::::::
echo.
echo  ===========================================
echo  ============ OCPN3 run complete ===========
echo  ===========================================
echo.
echo   Profiles %DAYS% days or older were deleted from %TARGET%
echo.
echo   Logfile is at:     %LOGPATH%\%LOGFILE%
echo   Accounts with the text "%EXCLUDE_PROFILES%" in their names were excluded.
echo.
set TARGET=
if %RUN_ONCE%==true goto end
goto single_pc_loop
:: ===================================================== ::
::             END OF SINGLE TARGET SECTION              ::
:: ===================================================== ::




:: ===================================================== ::
::           START OF MULTIPLE TARGET SECTION            ::
:: ===================================================== ::

:::::::::::::::::::::::::
:: COMMAND-LINE CHECKS ::
:::::::::::::::::::::::::
:multiple_pc_run_once
set RUN_ONCE=true
if '%AUTO%'=='auto' goto multiple_pc_go

:: If "days" wasn't set, go ahead and prompt user for it
if "%DAYS%"=="" (
	set DAYS=60
	echo.
	echo  Target: All computers listed in %NAMES_FILE%
	echo.
	set /P DAYS=  Nuke profiles older than how many days? [!DAYS!]: 
	if "!DAYS!"=="exit" exit /B 0
	)

:::::::::::::::
:: EXECUTION ::
:::::::::::::::
:multiple_pc_go
title Nuking profiles, please wait...

:: Make a temp directory for log compilation later
rmdir /s /q %TEMP%\OCPN3 >NUL
mkdir %TEMP%\OCPN3 >NUL

cls
echo.
echo  LETS ROCK!!
echo.
echo  Deleting cached profiles %DAYS% days and older on all
echo  systems listed in "%NAMES_FILE%".
echo.
echo  ===========================================
echo  ======== Beginning OCPN3 mass run =========
echo  ===========================================
echo.
echo  == Prepping targets...                   ==
echo.

:::::::::::::::::
:: TARGET PREP ::
:::::::::::::::::
:: Target prep:
::   1. Ping host
::   2. Make a logs directory if it doesn't already exist
::   3. Unlock and start the RemoteRegistry service
::   4. Report back for each host success or failure
for /F %%i in (%NAMES_FILE%) do (
	ping %%i -n 1 >NUL
	psexec -accepteula -n %CONNECTION_TIMEOUT% \\%%i cmd /c (sc config RemoteRegistry start= auto ^& net start RemoteRegistry ^& mkdir %SystemDrive%\Logs) 2>NUL
	:: Broken. Something to do with nested loops. eh. 
	::if %ERRORLEVEL%==0 echo     %%i ... OK
	::if %ERRORLEVEL%==1 echo     %%i ... FAILED
	)
echo.
echo  == Done.                                 ==
echo.
echo  == Deleting profiles on targets...       ==

::::::::::::::
:: DELETION ::
::::::::::::::
:: Do the actual profile deletion
:: Log each machine's results to an individual log file. 
:: Later we'll upload these logs individually, then compile them into a master log locally.
for /F %%i in (%NAMES_FILE%) do (
	ping %%i -n 1 >NUL
	delprof2 /U /I /C:\\%%i /D:%DAYS% /ED:%EXCLUDE_PROFILES% /ntuserini>> %TEMP%\OCPN3\%%i
	)

echo.
echo  == Done.                                 ==
echo.
echo  == 30 sec cooldown till log upload...    ==
ping localhost -n 30 >NUL
echo.
echo  == 15 sec cooldown remaining...          ==
ping localhost -n 15 >NUL
echo.
echo  == Cooldown done.                        ==
echo.
echo  == Beginning log upload...               ==
echo.

::::::::::::::::
:: LOG UPLOAD ::
::::::::::::::::
::  1. Ping the remote target
::  2. Copy the log from the profile deletion to the remote target's log directory
::  3. Report OK/FAILED on each copy operation
for /F %%i in (%NAMES_FILE%) do	(
	ping %%i -n 1 >NUL
	copy %TEMP%\OCPN3\%%i \\%%i\C$\Logs\%%i_OCPN3.log /Y >NUL
	if %ERRORLEVEL%==0 echo     %%i ... OK
	if %ERRORLEVEL%==1 echo     %%i ... FAILED
	)
echo.
echo  == Done.                                 ==

::::::::::::::::::
:: LOG ROTATION ::
::::::::::::::::::
echo.
echo  == Rotating master log...                ==
:: Log file rotation. Archives up to 7 backups, ".log" through ".log6". 
:: Rotate & age out master logs, then create new blank log
IF EXIST %LOGPATH%\OCPN3_master.log6 del %LOGPATH%\OCPN3_master.log6
IF EXIST %LOGPATH%\OCPN3_master.log5 rename %LOGPATH%\OCPN3_master.log5 OCPN3_master.log6
IF EXIST %LOGPATH%\OCPN3_master.log4 rename %LOGPATH%\OCPN3_master.log4 OCPN3_master.log5
IF EXIST %LOGPATH%\OCPN3_master.log3 rename %LOGPATH%\OCPN3_master.log3 OCPN3_master.log4
IF EXIST %LOGPATH%\OCPN3_master.log2 rename %LOGPATH%\OCPN3_master.log2 OCPN3_master.log3
IF EXIST %LOGPATH%\OCPN3_master.log1 rename %LOGPATH%\OCPN3_master.log OCPN3_master.log2
IF EXIST %LOGPATH%\OCPN3_master.log rename %LOGPATH%\OCPN3_master.log OCPN3_master.log1
echo. > %LOGPATH%\OCPN3_master.log
echo.
echo  == Done.                                 ==
echo.
echo  == Compiling log files...                ==

:::::::::::::::::::::
:: LOG COMPILATION ::
:::::::::::::::::::::
:: This loop compiles all the log files into a single master log.
:: It's ugly but it seems to work.
:: For each file in %TEMP%\OCPN3 of type any (*), insert it into the %%i variable and then:
::  1. Echo a blank line into the master log file
::  2. Echo the file name into the master log file
::  3. Echo a divider line into the master log file
::  4. Echo the contents of that system's logfile into the file
for /f %%i in (%NAMES_FILE%) do (
	echo. >> %LOGPATH%\OCPN3_master.log
	echo %%i >> %LOGPATH%\OCPN3_master.log
	echo ================================================================>>%LOGPATH%\OCPN3_master.log
	type %TEMP%\OCPN3\%%i >> %LOGPATH%\OCPN3_master.log
	)

:: old (alternate) way of doing it
REM FOR /r %TEMP%\OCPN3 %%i in (*) DO (
	REM echo. >> %LOGPATH%\OCPN3_master.log
	REM echo %%i >> %LOGPATH%\OCPN3_master.log
	REM echo ================================================================>>%LOGPATH%\OCPN3_master.log
	REM type %%i >> %LOGPATH%\OCPN3_master.log
	REM )
	

echo.
echo  == Done.                                 ==
echo.
echo  == Cleaning up...                        ==
rmdir %TEMP%\OCPN3 /S /Q
echo.
echo  == Done.                                 ==
echo.
echo  == THESE ACCOUNTS WERE DELETED:          ==
echo.
:: Display all deleted accounts
findstr "^\\[a-z]*" %LOGPATH%\OCPN3_master.log
echo.
echo  ===========================================
echo  ========= OCPN mass run complete ==========
echo  ===========================================
echo.
echo   All profiles %DAYS% days or older were deleted. 
echo   Logfile: %LOGPATH%\OCPN3_master.log
echo.
echo   Accounts with the text "%EXCLUDE_PROFILES%" in their name were excluded.
echo.
set TARGET=
if %RUN_ONCE%==true goto end
goto single_pc_loop

:: ===================================================== ::
::             END OF MULTIPLE TARGET SECTION            ::
:: ===================================================== ::

:end
ENDLOCAL