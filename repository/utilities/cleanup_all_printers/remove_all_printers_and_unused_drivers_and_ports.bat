:: WARNING!!! This script will remove EVERY installed printer, their ports, and the unused drivers.
:: Use with caution.
:: You have been warned.
:: Source: http://www.reddit.com/r/usefulscripts/comments/1c0698/batch_remove_all_printers_unused_drivers_and/


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
cd %SystemDrive%\Windows\System32
setLocal EnableDelayedExpansion
cls


:::::::::::::
:: EXECUTE ::
:::::::::::::
:: Stop the spooler service
net stop spooler

:: Determine OS
If exist "%SystemDrive%\Users\Default\NTUSER.DAT" goto Win7
If exist "%SystemDrive%\Documents and Settings\All Users\NTUSER.DAT" goto WinXP
 
:WinXP
cls
echo Removing all printers
:: Printer deletion
CSCRIPT /nologo %windir%\System32\prnmngr.vbs -x
 
:: Delete TCP/IP port
if exist %SystemDrive%\IPPorts.txt del %SystemDrive%\IPPorts.txt
if exist %SystemDrive%\IPPorts2.txt del %SystemDrive%\IPPorts2.txt
if exist %SystemDrive%\IPPorts3.txt del %SystemDrive%\IPPorts3.txt
cls
 
CSCRIPT /nologo %windir%\System32\prnport.vbs -l > %SystemDrive%\IPPorts.txt
type %SystemDrive%\IPPorts.txt | findstr IP_ > %SystemDrive%\IPPorts2.txt
for /f "tokens=* delims=" %%c in ('type %SystemDrive%\IPPorts2.txt') do (
 set LINE=%%c
 >> %SystemDrive%\IPPorts3.txt echo !LINE:~10!
)
for /f "delims=" %%x in (%SystemDrive%\IPPorts3.txt) do CSCRIPT /nologo %windir%\System32\prnport.vbs -d -r %%x
 
del %SystemDrive%\IPPorts.txt
del %SystemDrive%\IPPorts2.txt
del %SystemDrive%\IPPorts3.txt
 
:: Delete all un-used printer drivers
CSCRIPT /nologo %windir%\System32\prndrvr.vbs -x
 
goto Exit
 
:Win7
cls
Echo Removing all printers
:: Printer deletion
CSCRIPT /nologo %windir%\System32\Printing_Admin_Scripts\en-US\prnmngr.vbs -x
 
:: Delete TCP/IP port
if exist %SystemDrive%\IPPorts.txt del %SystemDrive%\IPPorts.txt
if exist %SystemDrive%\IPPorts2.txt del %SystemDrive%\IPPorts2.txt
if exist %SystemDrive%\IPPorts3.txt del %SystemDrive%\IPPorts3.txt
if exist %SystemDrive%\IPPorts4.txt del %SystemDrive%\IPPorts4.txt
cls
 
CSCRIPT /nologo %windir%\System32\Printing_Admin_Scripts\en-US\prnport.vbs -l > %SystemDrive%\IPPorts.txt
type %SystemDrive%\IPPorts.txt | findstr 172.20 > %SystemDrive%\IPPorts2.txt
type %SystemDrive%\IPPorts2.txt | findstr Port > %SystemDrive%\IPPorts3.txt
for /f "tokens=* delims=" %%c in ('type %SystemDrive%\IPPorts3.txt') do (
 set LINE=%%c
 >> %SystemDrive%\IPPorts4.txt echo !LINE:~10!
)
for /f "delims=" %%x in (%SystemDrive%\IPPorts4.txt) do CSCRIPT /nologo %windir%\System32\Printing_Admin_Scripts\en-US\prnport.vbs -d -r %%x
 
del %SystemDrive%\IPPorts.txt
del %SystemDrive%\IPPorts2.txt
del %SystemDrive%\IPPorts3.txt
del %SystemDrive%\IPPorts4.txt
 
:: Delete all used printer drivers
CSCRIPT /nologo %windir%\System32\Printing_Admin_Scripts\en-US\prndrvr.vbs -x
 
goto Exit

:Exit
net start spooler
