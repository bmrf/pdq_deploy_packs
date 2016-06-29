:: Purpose:       Purges UltraVNC, RealVNC and TightVNC servers from a target
:: Requirements:  Administrative access on target
:: Author:        Gregory Strike (http://www.gregorystrike.com/2012/02/29/script-to-uninstallremove-vnc-passively/), 2012-02-29
::                Modified by vocatus on reddit.com/r/sysadmin ( vocatus.gate@gmail.com ) // PGP key ID: 0x07d1490f82a211a2
::                ( http://www.reddit.com/r/sysadmin/comments/1wkdhh/pdq_deploy_packages_v134_includes_jre_7u51/ )
:: Version:       1.0.0 + Initial write


::::::::::
:: Prep :: -- Don't change anything in this section
::::::::::
SETLOCAL
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
:: Set your paths here. Don't use trailing slashes (\) in directory paths
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=%COMPUTERNAME%_remove_vnc.log


:::::::::::::
:: EXECUTE ::
:::::::::::::
echo %CUR_DATE% %TIME%   Executing VNC removal script.>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Executing VNC removal script.

:: Stop services
echo %CUR_DATE% %TIME%   Stopping services...>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Stopping services...
net stop winvnc >> %LOGPATH%\%LOGFILE%
net stop WinVNC4 >> %LOGPATH%\%LOGFILE%
net stop uvnc_service >> %LOGPATH%\%LOGFILE%
net stop tvnserver >> %LOGPATH%\%LOGFILE%

:: Kill left over processes
echo %CUR_DATE% %TIME%   Killing any possibly left over VNC processes...>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Killing any possibly left over VNC processes...
taskkill /F /IM winvnc.exe >> %LOGPATH%\%LOGFILE%
taskkill /F /IM winvnc4.exe >> %LOGPATH%\%LOGFILE%
taskkill /F /IM tvnserver.exe >> %LOGPATH%\%LOGFILE%

:: Delete services
echo %CUR_DATE% %TIME%   Deleting services...>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Deleting services...
sc delete winvnc >> %LOGPATH%\%LOGFILE%
sc delete WinVNC4 >> %LOGPATH%\%LOGFILE%
sc delete uvnc_service >> %LOGPATH%\%LOGFILE%
sc delete tvnserver >> %LOGPATH%\%LOGFILE%

:: Removes registry keys
echo %CUR_DATE% %TIME%   Removing HKEY_CLASSES_ROOT VNC keys... >> %LOGPATH%\%LOGFILE%
reg delete HKCR\.vnc /F >> %LOGPATH%\%LOGFILE%
reg delete HKCR\VNC.ConnectionInfo /F >> %LOGPATH%\%LOGFILE%
reg delete HKCR\VncViewer.Config /F >> %LOGPATH%\%LOGFILE%

echo %CUR_DATE% %TIME%   Removing HKEY_LOCAL_MACHINE VNC keys... >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\UltraVNC /F >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\ORL /F >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\RealVNC /F >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\TightVNC /F >> %LOGPATH%\%LOGFILE%

reg delete HKLM\SOFTWARE\Classes\Installer\Products\0CFB0D2C777F7664EB43FDDA06450BC2 /F >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\Classes\Installer\Features\0CFB0D2C777F7664EB43FDDA06450BC2 /F >> %LOGPATH%\%LOGFILE%

echo %CUR_DATE% %TIME%   Purging HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\...>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Purging HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\...
for /f "skip=2 tokens=*" %%X in ('REG QUERY HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\') do (
	reg delete "%%X\Components\57C6E5345D210A44998842E79B5BAD50" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\60FC611B29478454B9CCC507AE31AB91" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\8760511C47B4A704098BDBBF6FABBA1E" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\C41D6780D95C7F941859343ED8BC9241" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\DED58383173414A4091F8D2048078A4C" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\E6202AA71864F884C81B002320BB0549" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\FC5DB5C3632BA7541A9675A1C82083A8" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\16D1756551A3EDC6E8F5B6FFA037594A" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\2145043942A6E4124023181E6B7FDBF6" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\231519E4B428507098D8223B3A0A8F96" /F >> %LOGPATH%\%LOGFILE%	
	reg delete "%%X\Components\302B4E81CD72DE0B4F30CA2A3D6A4402" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\3D1E935A0099847E0B58B52CE24B589A" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\4BB1967F0DBB41EFAF7F4E9B5E5C5A24" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\4F9ECC71841010D31CAC655987A70628" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\531F2FBD7ECECDC7F6D67A9FCC8B942A" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\56FD6A56C21F936F424F73AE1B2E2B36" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\5878C68AAFC9FA10F0B4C6E8CA069047" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\5FD29712D83702BA4FCE0C96154D92C4" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\6B01529E7D5A5472649F01D30BC95E3A" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\7B6D9BB76DCB452B711C73C5A46F1B1B" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\7D296B2F4EB98AE91A0130F483557D6F" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\8F6AFAF4B2D541472FE33BCA458A141F" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\A318DADA61784AC25EC877CFFAECF3A4" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\AF07FC3002281089E82C09958495E1A4" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\C8948541143719FB0A313615829CF5A0" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\D439878C7F1352183C793E3D31D4A45D" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\E0AC44FD57660AA234EA024A277CAE3C" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\E2F011E639D0E9C6021B56BC9096CBD6" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Components\F77AC6157D51D1E3BD6343EA0E164BFA" /F >> %LOGPATH%\%LOGFILE%

	reg delete "%%X\Products\0CFB0D2C777F7664EB43FDDA06450BC2" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Products\A133C5C86D79ED64FB4F4842DB608A88" /F >> %LOGPATH%\%LOGFILE%
)

reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\RealVNC_is1" /F >> %LOGPATH%\%LOGFILE%
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\TightVNC_is1" /F >> %LOGPATH%\%LOGFILE%
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\Ultravnc2_is1" /F >> %LOGPATH%\%LOGFILE%
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Management\ARPCache\WinVNC_is1" /F >> %LOGPATH%\%LOGFILE%

reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{8C5C331A-97D6-46DE-BFF4-8424BD06A888} /F >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A8AD990E-355A-4413-8647-A9B168978423}_is1 /F >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{C2D0BFC0-F777-4667-BE34-DFAD6054B02C} /F >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Ultravnc2_is1 /F >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WinVNC_is1 /F >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\RealVNC_is1 /F >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\TightVNC_is1 /F >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\TightVNC /F >> %LOGPATH%\%LOGFILE%

reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v WinVNC /F >> %LOGPATH%\%LOGFILE%
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v tvncontrol /F >> %LOGPATH%\%LOGFILE%

:: Remove entries from control sets
echo %CUR_DATE% %TIME%   Removing ControlSet VNC keys...>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Removing ControlSet VNC keys...
for /f "tokens=*" %%X in ('REG QUERY HKLM\SYSTEM ^| FIND "ControlSet"') do (
	echo %CUR_DATE% %TIME%   %%X
	reg delete "%%X\Enum\Root\LEGACY_WINVNC" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Hardware Profiles\Current\System\CurrentControlSet\Services\vncdrv" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\winvnc" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\Eventlog\Application\WinVNC4" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\Eventlog\Application\UltraVnc" /F >> %LOGPATH%\%LOGFILE%
	
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List" /V "%SystemDrive%\Program Files\TightVNC\tvnserver.exe" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List" /V "%SystemDrive%\Program Files\TightVNC\vncviewer.exe" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List" /V "%SystemDrive%\Program Files\UltraVNC\vncviewer.exe" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\AuthorizedApplications\List" /V "%SystemDrive%\Program Files\UltraVNC\winvnc.exe" /F >> %LOGPATH%\%LOGFILE%
			
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\AuthorizedApplications\List" /V "%SystemDrive%\Program Files\TightVNC\tvnserver.exe" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\AuthorizedApplications\List" /V "%SystemDrive%\Program Files\TightVNC\vncviewer.exe" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\AuthorizedApplications\List" /V "%SystemDrive%\Program Files\UltraVNC\vncviewer.exe" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\AuthorizedApplications\List" /V "%SystemDrive%\Program Files\UltraVNC\winvnc.exe" /F >> %LOGPATH%\%LOGFILE%
		
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /V "{1F47EFAA-DD28-47CB-91B0-69E711BF1539}" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /V "{29C8E0DE-9408-4E24-AA51-B8A258135D0A}" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /V "{60AA5B63-27C2-4B88-BF81-9FED65C8E8C9}" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /V "{68A8E22B-6189-413A-8509-9F08B8651FB9}" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /V "{861F1EA6-034F-41E5-812B-EDED398FEBFC}" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules" /V "{CF337EB1-940B-46C1-8FD7-1A76CBE9E63B}" /F >> %LOGPATH%\%LOGFILE%
	
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List" /V "5800:TCP" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\GloballyOpenPorts\List" /V "5900:TCP" /F >> %LOGPATH%\%LOGFILE%
	
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List" /V "5800:TCP" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\GloballyOpenPorts\List" /V "5900:TCP" /F >> %LOGPATH%\%LOGFILE%	
)

:: Remove registry keys for any currently mounted user hives
echo %CUR_DATE% %TIME%   Removing VNC keys from mounted user hives...>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Removing VNC keys from mounted user hives...
for /f "skip=2 tokens=*" %%X in ('REG QUERY HKU') do (
	reg delete "%%X\Software\Microsoft\Installer\Products\A133C5C86D79ED64FB4F4842DB608A88" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\Software\ORL" /F >> %LOGPATH%\%LOGFILE%
	
	reg delete "%%X\AppEvents\EventLabels\VNCviewerBell" /F >> %LOGPATH%\%LOGFILE%
	reg delete "%%X\AppEvents\Schemes\Apps\VNCviewer" /F >> %LOGPATH%\%LOGFILE%
)

:: Windows XP and below
echo %CUR_DATE% %TIME%   Deleting VNC files from Pre-Vista profiles...>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Deleting VNC files from Pre-Vista profiles...
for /f "tokens=*" %%X in ('DIR /B /AD "%SystemDrive%\Documents and Settings\"') do (
	del /f /q "%SystemDrive%\Documents and Settings\%%X\Desktop\UltraVNC Viewer.lnk"
	del /f /q "%SystemDrive%\Documents and Settings\%%X\Desktop\UltraVNC Server.lnk"
	del /f /q "%SystemDrive%\Documents and Settings\%%X\Desktop\UltraVNC Settings.lnk"
	del /f /q "%SystemDrive%\Documents and Settings\%%X\Desktop\VNC Viewer.lnk"
	del /f /q "%SystemDrive%\Documents and Settings\%%X\Start Menu\Programs\UltraVNC.lnk"
	del /f /q "%SystemDrive%\Documents and Settings\%%X\Start Menu\Programs\UltraVNC Server.lnk"
	del /f /q "%SystemDrive%\Documents and Settings\%%X\Start Menu\Programs\UltraVNC Viewer.lnk"
	del /f /q "%SystemDrive%\Documents and Settings\%%X\Start Menu\Programs\UltraVNC Settings.lnk"
	
	rd /s /q "%SystemDrive%\Documents and Settings\%%X\Start Menu\Programs\TightVNC" 
	rd /s /q "%SystemDrive%\Documents and Settings\%%X\Start Menu\Programs\RealVNC" 
	rd /s /q "%SystemDrive%\Documents and Settings\%%X\Start Menu\Programs\UltraVNC" 
)

:: Windows Vista and above
echo %CUR_DATE% %TIME%   Deleting VNC files from post-Vista profiles...>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Deleting VNC files from post-Vista profiles...
for /f "tokens=*" %%X in ('DIR /B /AD "%SystemDrive%\Users\"') do (
	del /f /q "%SystemDrive%\Users\%%X\Desktop\UltraVNC Viewer.lnk"
	del /f /q "%SystemDrive%\Users\%%X\Desktop\UltraVNC Server.lnk"
	del /f /q "%SystemDrive%\Users\%%X\Desktop\UltraVNC Settings.lnk"
	del /f /q "%SystemDrive%\Users\%%X\Desktop\VNC Viewer.lnk"
	del /f /q "%SystemDrive%\Users\%%X\Start Menu\Programs\UltraVNC.lnk"
	del /f /q "%SystemDrive%\Users\%%X\Start Menu\Programs\UltraVNC Server.lnk"
	del /f /q "%SystemDrive%\Users\%%X\Start Menu\Programs\UltraVNC Viewer.lnk"
	del /f /q "%SystemDrive%\Users\%%X\Start Menu\Programs\UltraVNC Settings.lnk"

	rd /s /q "%SystemDrive%\Users\%%X\Start Menu\Programs\TightVNC" 
	rd /s /q "%SystemDrive%\Users\%%X\Start Menu\Programs\RealVNC" 
	rd /s /q "%SystemDrive%\Users\%%X\Start Menu\Programs\UltraVNC" 
)

:: 'All Users' in Vista and Beyond
echo %CUR_DATE% %TIME%   Deleting VNC files from post-Vista All Users profile...>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Deleting VNC files from post-Vista All Users profile...
del /f /q "%ProgramData%\Desktop\UltraVNC Viewer.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%ProgramData%\Desktop\UltraVNC Server.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%ProgramData%\Desktop\UltraVNC Settings.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%ProgramData%\Desktop\VNC Viewer.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\UltraVNC.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\UltraVNC Server.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\UltraVNC Viewer.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\UltraVNC Settings.lnk" >> %LOGPATH%\%LOGFILE%

rd /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\TightVNC" >> %LOGPATH%\%LOGFILE%
rd /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\RealVNC" >> %LOGPATH%\%LOGFILE%
rd /s /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\UltraVNC">> %LOGPATH%\%LOGFILE%

:: If running as a user with folder redirection
:: THIS WORKS in MY ENVIRONMENT.  You may have to modify the locations.
echo %CUR_DATE% %TIME%   Deleting shortcuts...>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Deleting shortcuts...
del /f /q "%HOMESHARE%\Desktop\UltraVNC Viewer.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%HOMESHARE%\Desktop\UltraVNC Server.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%HOMESHARE%\Desktop\UltraVNC Settings.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%HOMESHARE%\Desktop\VNC Viewer.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%HOMESHARE%\Start Menu\Programs\UltraVNC.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%HOMESHARE%\Start Menu\Programs\UltraVNC Server.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%HOMESHARE%\Start Menu\Programs\UltraVNC Viewer.lnk" >> %LOGPATH%\%LOGFILE%
del /f /q "%HOMESHARE%\Start Menu\Programs\UltraVNC Settings.lnk" >> %LOGPATH%\%LOGFILE%

rd /s /q "%HOMESHARE%\Start Menu\Programs\TightVNC" >> %LOGPATH%\%LOGFILE%
rd /s /q "%HOMESHARE%\Start Menu\Programs\RealVNC" >> %LOGPATH%\%LOGFILE%
rd /s /q "%HOMESHARE%\Start Menu\Programs\UltraVNC" >> %LOGPATH%\%LOGFILE%

:: Remove VNC Program Files
echo %CUR_DATE% %TIME%   Deleting leftover files in Program Files...>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Deleting leftover files in Program Files...
rd /s /q "%ProgramFiles%\UltraVNC"
rd /s /q "%ProgramFiles%\uvnc bvba"
rd /s /q "%ProgramFiles%\RealVNC"
rd /s /q "%ProgramFiles%\TightVNC"

rd /s /q "%ProgramFiles% (x86)\UltraVNC"
rd /s /q "%ProgramFiles% (x86)\uvnc bvba"
rd /s /q "%ProgramFiles% (x86)\RealVNC"
rd /s /q "%ProgramFiles% (x86)\TightVNC"

echo %CUR_DATE% %TIME%   Done. Recommend rebooting.>> %LOGPATH%\%LOGFILE%
echo %CUR_DATE% %TIME%   Done. Recommend rebooting.

:: Pop back to original directory. This isn't necessary in stand-alone runs of the script, but is needed when being called from another script
popd

:: Return exit code to SCCM/PDQ Deploy/etc
exit /B %EXIT_CODE%
