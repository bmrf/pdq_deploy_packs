@echo off

echo.
echo  Are you sure?
echo.
pause >NUL


echo.
echo  %TIME%
echo  Calculating SHA256 hashes of PDQ Pack, please wait...
echo.

pushd "\\thebrain\Downloads\seeders\PDQ Pack\integrity_verification"
if exist %TEMP%\checksums.txt del %TEMP%\checksums.txt
if exist checksums.txt del checksums.txt
if exist checksums.txt.sig del checksums.txt.sig
cd ..
%SystemRoot%\syswow64\hashdeep64.exe -s -c sha256 -l -r .\ > %TEMP%\checksums.txt
::%SystemRoot%\system32\hashdeep.exe -s -c sha256 -l -r .\ > %TEMP%\checksums.txt

:: verify
echo.
echo  Verifying...
echo.
%SystemRoot%\syswow64\hashdeep64.exe -s -l -r -a -k %TEMP%\checksums.txt .\
::%SystemRoot%\system32\hashdeep.exe -s -l -r -a -k %TEMP%\checksums.txt .\

:: assuming everything went alright, deposit the file in our directory
move %TEMP%\checksums.txt "integrity_verification\checksums.txt" >NUL
popd


echo.
echo  %TIME%
echo  Done. Don't forget to sign 'checksums.txt' before publishing.
echo.
color 2a
pause >NUL
