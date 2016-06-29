'Script to clean up orphaned printer ports that hog memory in the print spooler.
'Detects OS by getting major version number.
'Must be run from an elevated prompt (administrator elevated privileges)
'Adjusted by Bo Riis, bri@dandomain.dk
'Source: http://www.brianmadden.com/forums/t/15257.aspx

Const HKEY_LOCAL_MACHINE = &H80000002
CONST BASEKEY2008 = "SYSTEM\CurrentControlSet\Control\DeviceClasses\{28d78fad-5a12-11d1-ae5b-0000f803a8c2}\##?#Root#RDPBUS#0000#{28d78fad-5a12-11d1-ae5b-0000f803a8c2}" 
CONST BASEKEY2003 = "SYSTEM\CurrentControlSet\Control\DeviceClasses\{28d78fad-5a12-11d1-ae5b-0000f803a8c2}\##?#Root#RDPDR#0000#{28d78fad-5a12-11d1-ae5b-0000f803a8c2}"
CONST VALUENAME = "Port Description" 
CONST ForReading = 1, ForWriting = 2, ForAppending = 8
CONST DEBUGLOG = False
CONST WRITETOLOGFILE = True		'Writes date and number of deleted items. Enable DEBUGLOG for exhaustive onscreen logging.

strComputer = "."

If DEBUGLOG Then WScript.Echo "DEBUG LOGGING ENABLED!"

Set dtmConvertedDate = CreateObject("WbemScripting.SWbemDateTime")
Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set oss = objWMIService.ExecQuery ("Select * from Win32_OperatingSystem")

Set oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & _ 
strComputer & "\root\default:StdRegProv") 

If WRITETOLOGFILE Then strLogFile = "C:\Logs\CleanupOrphanedPrinters.log"
If WRITETOLOGFILE Then Set objFSO = CreateObject("Scripting.FileSystemObject")
If WRITETOLOGFILE Then Set objLogFile = objFSO.OpenTextFile(strLogFile, ForAppending, True)

'Detect OS version and set the BASEKEY accordingly.
BASEKEY = OSproperties
If DEBUGLOG Then Wscript.Echo "RegKey start root: " & BASEKEY

oReg.EnumKey HKEY_LOCAL_MACHINE, BASEKEY, arrDeviceKeys 

If IsArray(arrDeviceKeys) then
	Dim deletedkeyscounter
	deletedkeyscounter = 0
	For Each strDeviceKey in arrDeviceKeys
		If DEBUGLOG Then WScript.Echo "------------------------------------------------------------------------"
		If DEBUGLOG Then WScript.Echo "Checking : " & strDeviceKey 
		strParametersPath = BASEKEY & "\" & strDeviceKey & "\Device Parameters" 
		If DEBUGLOG Then WScript.Echo strParametersPath 
		oReg.GetStringValue HKEY_LOCAL_MACHINE,strParametersPath,VALUENAME,strValue 
		If DEBUGLOG Then WScript.Echo " Port Description : " & strValue 

		if strValue = "Inactive TS Port" then 
			strDevicePath = BASEKEY & "\" & strDeviceKey 
			If DEBUGLOG Then WScript.Echo " Deleting from : " & strDevicePath 
			'If WRITETOLOGFILE Then WriteLog "Deleting key: " & strDevicePath
			deletedkeyscounter = deletedkeyscounter +1
			DeleteSubKeys HKEY_LOCAL_MACHINE, strDevicePath
		end if 
	Next 
End If 

If WRITETOLOGFILE Then WriteLog "Number of deleted orphaned printers: " & deletedkeyscounter

'DeleteSubkeys copied (and slightly modified) from http://www.microsoft.com/technet/technetmag/issues/2006/08/ScriptingGuy/default.aspx 
Sub DeleteSubkeys(HKEY_LOCAL_MACHINE, strKeyPath) 
	oReg.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubkeys
	If IsArray(arrSubkeys) Then 
		For Each strSubkey In arrSubkeys 
		DeleteSubkeys HKEY_LOCAL_MACHINE, strKeyPath & "\" & strSubkey 
		Next 
	End If 

	If DEBUGLOG Then WScript.Echo " Delete : " & strKeyPath
	oReg.DeleteKey HKEY_LOCAL_MACHINE, strKeyPath
End Sub

Function OSproperties
	For Each os in oss
		If DEBUGLOG Then Wscript.Echo "OS: " & os.Caption
		If DEBUGLOG Then Wscript.Echo "Windows Version: " & os.Version
		intOSVer = os.Version
		dtmConvertedDate.Value = os.InstallDate
		dtmInstallDate = dtmConvertedDate.GetVarDate
		If DEBUGLOG Then Wscript.Echo "Install Date: " & dtmInstallDate
	Next
	dwMajorVersion = Left(intOSVer,1)
	If DEBUGLOG Then Wscript.Echo "dwMajorVersion: " & dwMajorVersion
	Select Case dwMajorVersion
		Case 6	'Windows Vista, Server 2008 and Server 2008 R2
			tmpBASEKEY = BASEKEY2008
		Case 5	'Windows 2000, XP and 2003
			tmpBASEKEY = BASEKEY2003
		Case Else
			Wscript.Echo "ERROR: Operating system not supported or couldn't detect OS Version......quitting!"
			Wscript.Quit
	End Select
	OSproperties = tmpBASEKEY
End Function

Sub WriteLog(strLogText)
	logTime = Now()
	strLogLine = logTime & ": " & strLogText
	objLogFile.WriteLine(strLogLine)
End Sub

Set dtmConvertedDate = Nothing
Set objWMIService = Nothing
Set oss = Nothing
Set oReg = Nothing
If WRITETOLOGFILE Then objLogFile.Close
If WRITETOLOGFILE Then Set objFSO = Nothing
If WRITETOLOGFILE Then Set objLogFile = Nothing

WScript.Quit