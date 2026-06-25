@echo off
title Auto WiFi Connector
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
pause
exit
