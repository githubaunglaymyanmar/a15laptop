@echo off
title Remove OEM3 Driver + Hidden Devices
color 0C

:: Run as Admin Check
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Run this file as Administrator.
    pause
    exit
)

echo =========================================
echo Removing driver package: oem3.inf
echo =========================================


set devmgr_show_nonpresent_devices=1


pnputil /delete-driver oem3.inf /uninstall /force

echo.
echo =========================================
echo Removing hidden Realtek devices
echo =========================================

powershell -NoProfile -ExecutionPolicy Bypass ^
"Get-PnpDevice -PresentOnly:$false -Class Net | Where-Object {$_.FriendlyName -like '*Realtek*'} | ForEach-Object { try { pnputil /remove-device $_.InstanceId } catch {} }"

netsh winsock reset 
netsh int ip reset
ipconfig /release 
ipconfig /renew 
ipconfig /flushdns


echo.
echo =========================================
echo Completed. Restart Windows.
echo =========================================

pause
