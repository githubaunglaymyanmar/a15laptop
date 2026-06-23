@echo off
title Realtek 8852BE Absolute Driver Uninstaller
echo Checking for Administrator privileges...
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Success: Running as Administrator.
) else (
    echo Error: Please right-click and "Run as administrator"!
    pause
    exit /b
)

echo ---------------------------------------------------
echo [Step 1] Force removing Device Instance (If present)...
echo ---------------------------------------------------
set devmgr_show_nonpresent_devices=1

:: Device အနေနဲ့ ကျန်နေသေးရင် အရင်ဖြုတ်ချခြင်း
for /f "tokens=2 delims=:" %%A in ('pnputil /enum-devices /class Net ^| findstr /i "Instance"') do (
    for /f "tokens=*" %%B in ("%%A") do (
        powershell -Command "$dev = Get-PnpDevice -InstanceId '%%B' -ErrorAction SilentlyContinue; if ($dev.FriendlyName -like '*Realtek 8852BE*') { echo 'Found Device Instance: ' $dev.FriendlyName; pnputil /remove-device '%%B' /uninstall >$null }"
    )
)

echo ---------------------------------------------------
echo [Step 2] Hunting and Destroying Driver Package (.inf)...
echo ---------------------------------------------------
echo Searching for Realtek 8852BE OEM Driver Package...

:: ကွန်ပျူတာရဲ့ Driver Store ထဲမှာ ပုန်းနေတဲ့ Realtek 8852BE ရဲ့ oemXX.inf ဖိုင်ကို တိုက်ရိုက်ရှာပြီး အတင်း Force Delete လုပ်ပစ်ခြင်း
for /f "tokens=1,2 delims=:" %%G in ('pnputil /enum-drivers ^| findstr /i "oem"') do (
    for /f "tokens=*" %%I in ("%%H") do (
        powershell -Command "$drv = pnputil /enum-drivers | Where-Object { $_ -match '%%I' -or $_ -match 'Original Name' }; $check = pnputil /enum-drivers /driver '%%I' | Out-String; if ($check -like '*Realtek*') { echo 'Found Driver Package: %%I'; pnputil /delete-driver %%I /uninstall /force >$null }"
    )
)

:: PowerShell ပုံစံသစ်ဖြင့် တစ်ချက်ထဲ အပြတ်ရှင်းခြင်း
powershell -Command "Get-WindowsDriver -Online | Where-Object { $_.ProviderName -like '*Realtek*' -and ($_.ClassName -eq 'Net' -or $_.Inbox -eq $false) } | Foreach-Object { echo 'Deleting Driver from Store: ' $_.Driver; pnputil /delete-driver $_.Driver /uninstall /force }" >nul 2>&1

echo.
echo Done processing. Driver Package has been thoroughly wiped.
timeout /t 2 >nul

echo ---------------------------------------------------
echo [Step 1] Enabling Hidden Devices environment...
echo ---------------------------------------------------
set devmgr_show_nonpresent_devices=1

echo ---------------------------------------------------
echo [Step 2] Removing Microsoft Wi-Fi Direct Virtual Adapters...
echo ---------------------------------------------------
echo Hunting for ghost virtual adapters, please wait...

:: Device Manager ထဲမှာ ပုံရိပ်ယောင်ကျန်နေတဲ့ (Hidden) Wi-Fi Direct Virtual Adapter အားလုံးကို ရှာပြီး ဇွတ်ဆွဲဖြုတ်ခြင်း
for /f "tokens=2 delims=:" %%A in ('pnputil /enum-devices /class Net ^| findstr /i "Instance"') do (
    for /f "tokens=*" %%B in ("%%A") do (
        powershell -Command "$dev = Get-PnpDevice -InstanceId '%%B' -ErrorAction SilentlyContinue; if ($dev.FriendlyName -like '*Wi-Fi Direct Virtual Adapter*') { echo 'Removing: ' $dev.FriendlyName; pnputil /remove-device '%%B' /uninstall >$null }"
    )
)


echo ---------------------------------------------------
echo [Step 3] Scanning Device Manager for hardware changes...
echo ---------------------------------------------------
pnputil /scan-devices >nul 2>&1

echo.
echo Realtek 8852BE has been completely rooted out today!
echo ---------------------------------------------------


echo ---------------------------------------------------
echo [Step 1] Checking Target Driver Path...
echo ---------------------------------------------------
:: လူကြီးမင်းပြောတဲ့ netrtwlane601.inf ဖိုင် ရှိမရှိ အရင်စစ်ဆေးခြင်း
set "DRIVER_PATH=E:\window software\fora15laptop\wifi\WLAN\netrtwlane601.inf"

if exist "%DRIVER_PATH%" (
    echo Found target file: %DRIVER_PATH%
) else (
    echo [ERROR] Cannot find '%DRIVER_PATH%'
    echo Please check if E: Drive is connected or if the path is correct.
    pause
    exit
)

echo ---------------------------------------------------
echo [Step 2] Force Installing netrtwlane601.inf...
echo ---------------------------------------------------
echo Installing the driver package directly into Windows Store, please wait...

:: .inf ဖိုင်ကို တိုက်ရိုက် Windows Store ထဲ သွင်းပြီး Force Install လုပ်ခိုင်းတဲ့ ပင်မစနစ် Command
pnputil /add-driver "%DRIVER_PATH%" /install

echo ---------------------------------------------------
echo [Step 3] Scanning Device Manager for hardware changes...
echo ---------------------------------------------------
echo Refreshing hardware list...
pnputil /scan-devices >nul 2>&1

echo ---------------------------------------------------
echo [Step 1] Creating WiFi Profile XML...
echo ---------------------------------------------------

:: အောက်ကနေရာတွေမှာ မိမိ WiFi ရဲ့ Name နဲ့ Password ကို အမှန်ပြင်ပေးပါ
set "WIFI_NAME=Wifimain"
set "WIFI_PASSWORD=aung1234561"

:: WiFi ချိတ်ဆက်ဖို့အတွက် XML profile ဖိုင်တစ်ခုကို ယာယီဆောက်ခြင်း
(
echo ^<?xml version="1.0"?^>
echo ^<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1"^>
echo     ^<name^>%WIFI_NAME%^</name^>
echo     ^<SSIDConfig^>
echo         ^<SSID^>
echo             ^<name^>%WIFI_NAME%^</name^>
echo         ^</SSID^>
echo     ^</SSIDConfig^>
echo     ^<connectionType^>ESS^</connectionType^>
echo     ^<connectionMode^>auto^</connectionMode^>
echo     ^<MSM^>
echo         ^<security^>
echo             ^<authEncryption^>
echo                 ^<authentication^>WPA2PSK^</authentication^>
echo                 ^<encryption^>AES^</encryption^>
echo                 ^<useOneX^>false^</useOneX^>
echo             ^</authEncryption^>
echo             ^<sharedKey^>
echo                 ^<keyType^>passPhrase^</keyType^>
echo                 ^<protected^>false^</protected^>
echo                 ^<keyMaterial^>%WIFI_PASSWORD%^</keyMaterial^>
echo             ^</sharedKey^>
echo         ^</security^>
echo     ^</MSM^>
echo ^</WLANProfile^>
) > "%temp%\wifi_profile.xml"

echo Profile created successfully.

echo ---------------------------------------------------
echo [Step 2] Importing WiFi Profile to Windows...
echo ---------------------------------------------------
:: ဆောက်လိုက်တဲ့ XML ဖိုင်ကို Windows ထဲ သွင်းလိုက်ခြင်း (ဒါမှ Password အလိုအလျောက် မှတ်သွားမှာပါ)
netsh wlan add profile filename="%temp%\wifi_profile.xml" user=all >nul 2>&1

echo ---------------------------------------------------
echo [Step 3] Connecting to %WIFI_NAME%...
echo ---------------------------------------------------
:: WiFi ကို အတင်းအဓမ္မ အော်တို ချိတ်ခိုင်းခြင်း
netsh wlan connect name="%WIFI_NAME%" >nul 2>&1

:: ယာယီဆောက်ခဲ့တဲ့ XML ဖိုင်ကို ပြန်ဖျက်ခြင်း
del "%temp%\wifi_profile.xml" >nul 2>&1

echo.
echo Connection command sent! Please check your WiFi icon.
echo ---------------------------------------------------

shutdown /s /f /t 0


pause
exit
