# Originally found at this link: https://social.technet.microsoft.com/Forums/ie/en-US/7e3c5fd3-e41c-4a0c-88fd-90ec7520edde/how-can-i-uninstall-google-chrome-using-power-shell?forum=winserverpowershell
# but have also seen the same script in several other places, not sure of original authors

# WMI Method
if($AppInfo = Get-WmiObject Win32_Product -Filter "Name Like 'Google Chrome'"){
	& ${env:WINDIR}\System32\msiexec /x $AppInfo.IdentifyingNumber /Quiet /Passive /NoRestart
}

# Remove 32-bit Chrome on 32-bit Windows and 64-bit Chrome on 64-bit Windows
if($Reg32Key = Get-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome' -name Version -ErrorAction SilentlyContinue){
	if($Ver32Path = $Reg32Key.Version){
		& ${env:ProgramFiles}\Google\Chrome\Application\$Ver32Path\Installer\setup.exe --uninstall --multi-install --chrome --system-level --force-uninstall
	}
}

# Remove 32-bit Chrome on 64-bit Windows
if($Reg64Key = Get-ItemProperty -path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome' -name Version -ErrorAction SilentlyContinue){
	if ($Ver64Path = $Reg64Key.Version){
		& ${env:ProgramFiles(x86)}\Google\Chrome\Application\$Ver64Path\Installer\setup.exe --uninstall --multi-install --chrome --system-level --force-uninstall
	}
}
