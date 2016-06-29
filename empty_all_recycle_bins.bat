:: This empties all recycle bins on Windows 7 and up
rmdir /s /q %SystemDrive%\$Recycle.Bin 2>NUL

:: This empties all recycle bins on Windows XP and Server 2003
rmdir /s /q %SystemDrive%\RECYCLER 2>NUL

:: Return exit code to calling application
exit /B 0