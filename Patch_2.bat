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
title ASTORIA PATCH (Part 2)
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
if not exist "%MainOS%\EFIESP\efi\Microsoft\Boot\BCD" color 04&pause >nul | set /p =Make sure your MainOS is %MainOS%&echo.&goto Start
cls
color 0a
echo Processing . . .
REM // Injecting apps
xcopy /y "%CD%\Bin\Apps\*.appx" "%MainOS%\Programs\CommonFiles\Xaps\" >nul 2>&1
xcopy /ey "%CD%\Bin\Apps" "%MainOS%\Data\Users\Public\Downloads\Apps\" >nul 2>&1
del /q /f "%MainOS%\Programs\CommonFiles\Xaps\Com.Cpuid.CPU_Z.appx" >nul 2>&1
REM // Creating links between Windows and AOW
mklink /j "%MainOS%\Data\Users\Public\Android Storage" "C:\Data\Users\DefApps\AppData\Local\Aow\mnt\shell\emulated\0\" >nul 2>&1
xcopy /y "%CD%\Bin\MainOS.lnk" "%MainOS%\Data\Users\Public\" >nul 2>&1
cls
color f3
echo Done!! 
pause >nul | set /p =Reboot the device and install all the apps under Downloads folder.
exit