@echo off
chcp 65001 >nul
title Start AstrBot + SnowLuma
echo Starting AstrBot v4.29.3 (supervised, auto-restart) ...
start "AstrBot v4.29.3" cmd /c "<WORKSPACE>\start-astrbot-supervised.cmd"
echo Waiting for AstrBot OneBot reverse-WS server on 6199 ...
timeout /t 12 /nobreak >nul
echo Starting SnowLuma v2.2.0 ...
start "SnowLuma 2.2.0" cmd /c "<WORKSPACE>\snowluma-launch.bat"
echo.
echo  AstrBot WebUI : http://127.0.0.1:6185   (user astrbot)
echo  SnowLuma WebUI: http://127.0.0.1:5099   (password <REDACTED_PASSWORD>)
echo.
pause
