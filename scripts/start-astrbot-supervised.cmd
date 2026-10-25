@echo off
rem ============================================================
rem  AstrBot v4.29.3 supervised launcher
rem  WebUI:  http://127.0.0.1:6185
rem  OneBot: ws://127.0.0.1:6199/ws (reverse WebSocket server)
rem  Auto-restarts when AstrBot exits (incl. WebUI restart button).
rem  Close this window to stop completely.
rem ============================================================
title AstrBot v4.29.3 (supervised)
cd /d "<WORKSPACE>\astrbot"
set PYTHONIOENCODING=utf-8
set PYTHONUTF8=1
set UV_CACHE_DIR=<WORKSPACE>\install\uv-cache
set UV_PYTHON_INSTALL_DIR=<WORKSPACE>\install\uv-python
if not exist logs mkdir logs
:loop
echo.
echo  Starting AstrBot v4.29.3 ...
echo  WebUI : http://127.0.0.1:6185   (user: astrbot)
echo  OneBot: ws://127.0.0.1:6199/ws
echo.
".venv\Scripts\python.exe" main.py
set RC=%ERRORLEVEL%
echo.
echo  AstrBot exited with code %RC%. Restarting in 3 seconds...
echo  Close this window or press Ctrl+C to stop completely.
timeout /t 3 /nobreak >nul
goto loop
