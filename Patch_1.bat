:Start
@echo off
REM // Getting administrator privileges
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UserAccountControl
) else ( goto GotAdministrator )
:UserAccountControl
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
:GotAdministrator
    pushd "%CD%"
    CD /D "%~dp0"
mode con: cols=70 lines=15
title ASTORIA PATCH (Part 1)
color 05
REM // Asking for MainOS letter
choice /n /c abcdefghijklmnopqrstuvwxyz /m "Enter MainOS partition:"
if errorlevel 26 set MainOS=Z:&goto MainOS
if errorlevel 25 set MainOS=Y:&goto MainOS
if errorlevel 24 set MainOS=X:&goto MainOS
if errorlevel 23 set MainOS=W:&goto MainOS
if errorlevel 22 set MainOS=V:&goto MainOS
if errorlevel 21 set MainOS=U:&goto MainOS
if errorlevel 20 set MainOS=T:&goto MainOS
if errorlevel 19 set MainOS=S:&goto MainOS
if errorlevel 18 set MainOS=R:&goto MainOS
if errorlevel 17 set MainOS=Q:&goto MainOS
if errorlevel 16 set MainOS=P:&goto MainOS
if errorlevel 15 set MainOS=O:&goto MainOS
if errorlevel 14 set MainOS=N:&goto MainOS
if errorlevel 13 set MainOS=M:&goto MainOS
if errorlevel 12 set MainOS=L:&goto MainOS
if errorlevel 11 set MainOS=K:&goto MainOS
if errorlevel 10 set MainOS=J:&goto MainOS
if errorlevel 9 set MainOS=I:&goto MainOS
if errorlevel 8 set MainOS=H:&goto MainOS
if errorlevel 7 set MainOS=G:&goto MainOS
if errorlevel 6 set MainOS=F:&goto MainOS
if errorlevel 5 set MainOS=E:&goto MainOS
if errorlevel 4 set MainOS=D:&goto MainOS
if errorlevel 3 set MainOS=C:&goto MainOS
if errorlevel 2 set MainOS=B:&goto MainOS
if errorlevel 1 set MainOS=A:&goto MainOS
:MainOS
if not exist "%MainOS%\EFIESP\efi\Microsoft\Boot\BCD" color 04&echo.&pause >nul | set /p =Make sure your MainOS is %MainOS%&goto Start
set BCD="%MainOS%\EFIESP\efi\Microsoft\Boot\BCD"
cls
color 0a
echo Processing . . .
reg load HKLM\LSOFTWARE "%MainOS%\Windows\System32\Config\SOFTWARE" >nul 2>&1
REM // Placing flight token and enabling testsigning
xcopy /y "%CD%\Bin\SbcpFlightToken.p7b" "%MainOS%\Efiesp\efi\Microsoft\Boot\policies\" >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {311b88b5-9b30-491d-bad9-167ca3e2d417} testsigning on >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {default} testsigning on >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {01de5a27-8705-40db-bad6-96fa5187d4a6} testsigning on >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {bootmgr} testsigning on >nul 2>&1
REM // Injecting Developer Menu
xcopy /ey "%CD%\Bin\DeveloperMenu" "%MainOS%\Efiesp\Windows\system32\boot\" >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /create {DCC0BD7C-ED9D-49D6-AF62-23A3D901117B} /d "Developer Menu" /application bootapp >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {DCC0BD7C-ED9D-49D6-AF62-23A3D901117B} path \windows\system32\BOOT\developermenu.efi >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {DCC0BD7C-ED9D-49D6-AF62-23A3D901117B} device partition=%MainOS%\Efiesp >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {DCC0BD7C-ED9D-49D6-AF62-23A3D901117B} inherit {bootloadersettings} >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {DCC0BD7C-ED9D-49D6-AF62-23A3D901117B} nointegritychecks yes >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {DCC0BD7C-ED9D-49D6-AF62-23A3D901117B} testsigning yes >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {DCC0BD7C-ED9D-49D6-AF62-23A3D901117B} isolatedcontext yes >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {bootmgr} custom:54000001 {default} >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {bootmgr} custom:54000002 {DCC0BD7C-ED9D-49D6-AF62-23A3D901117B} >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {bootmgr} displaybootmenu yes >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {bootmgr} timeout 6 >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /set {default} description "Windows Phone" >nul 2>&1
"%CD%\Bin\bcdedit" /store %BCD% /displayorder "{default}" "{DCC0BD7C-ED9D-49D6-AF62-23A3D901117B}" >nul 2>&1
REM // Enabling developer mode and disabling Windows update
reg add HKLM\LSOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock /v AllowDevelopmentWithoutDevLicense /t REG_DWORD /d 1 /f >nul 2>&1
reg add HKLM\LSOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock /v AllowAllTrustedApps /t REG_DWORD /d 1 /f >nul 2>&1
reg add HKLM\LSOFTWARE\Microsoft\Windows\CurrentVersion\DeviceUpdate\Agent\Settings /v GuidOfCategoryToScan /t REG_SZ /d 00000000-0000-0000-0000-000000000000 /f >nul 2>&1
reg unload HKLM\LSOFTWARE >nul 2>&1
REM // Making the tweaks permanent
if not exist "%MainOS%\Windows\Packages\registryFiles\OEMSettings.reg" cls&color f3&pause >nul | set /p =Done!!&exit
attrib -s "%MainOS%\Windows\Packages\registryFiles\OEMSettings.reg" >nul 2>&1
ren "%MainOS%\Windows\Packages\registryFiles\OEMSettings.reg" "OEMSettings.gz" >nul 2>&1
"%CD%\Bin\7za" e "%MainOS%\Windows\Packages\registryFiles\OEMSettings.gz" -o"%MainOS%\Windows\Packages\registryFiles\" >nul 2>&1
if exist "%MainOS%\Windows\Packages\registryFiles\OEMSettings" (set "wp8=0") else (ren "%MainOS%\Windows\Packages\registryFiles\OEMSettings.gz" "OEMSettings" >nul 2>&1&set "wp8=1")
cmd /u /c echo.>>"%MainOS%\Windows\Packages\registryFiles\OEMSettings"
cmd /u /c echo>>"%MainOS%\Windows\Packages\registryFiles\OEMSettings" [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceUpdate\Agent\Settings]
cmd /u /c echo>>"%MainOS%\Windows\Packages\registryFiles\OEMSettings" "GuidOfCategoryToScan"="00000000-0000-0000-0000-000000000000"
if "%wp8%"=="0" ("%CD%\Bin\7za" u "%MainOS%\Windows\Packages\registryFiles\OEMSettings.gz" "%MainOS%\Windows\Packages\registryFiles\OEMSettings" >nul 2>&1
ren "%MainOS%\Windows\Packages\registryFiles\OEMSettings.gz" "OEMSettings.reg" >nul 2>&1) else (ren "%MainOS%\Windows\Packages\registryFiles\OEMSettings" "OEMSettings.reg" >nul 2>&1)
attrib +s "%MainOS%\Windows\Packages\registryFiles\OEMSettings.reg" >nul 2>&1
del "%MainOS%\Windows\Packages\registryFiles\OEMSettings" >nul 2>&1
cls
color f3
pause >nul | set /p =Done!!
exit