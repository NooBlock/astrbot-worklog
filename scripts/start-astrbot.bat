@echo off
rem ============================================================
rem  AstrBot v4.29.3 launcher (OneBot v11 / SnowLuma bridge)
rem  WebUI:   http://127.0.0.1:6185
rem  OneBot:  ws://127.0.0.1:6199/ws  (reverse WebSocket server)
rem ============================================================
title AstrBot v4.29.3
cd /d "<WORKSPACE>\astrbot"

set PYTHONIOENCODING=utf-8
set PYTHONUTF8=1
rem pip: avoid writing the (sandbox/ACL denied) user pip cache - otherwise pip's tempfile retry loop burns 100% CPU
set PIP_NO_CACHE_DIR=1
set PIP_DISABLE_PIP_VERSION_CHECK=1
rem uv cache/interpreter live inside the project because %LOCALAPPDATA% is sandbox/ACL denied
set UV_CACHE_DIR=<WORKSPACE>\install\uv-cache
set UV_PYTHON_INSTALL_DIR=<WORKSPACE>\install\uv-python

if not exist logs mkdir logs

echo.
echo  Starting AstrBot v4.29.3 ...
echo  WebUI : http://127.0.0.1:6185   (user: astrbot)
echo  OneBot: ws://127.0.0.1:6199/ws (reverse WebSocket server, path /ws)
echo.

rem Direct venv interpreter (no `uv run` needed; `uv run main.py` also works when
rem UV_CACHE_DIR above is set, but it re-syncs the project on every start).
".venv\Scripts\python.exe" main.py

echo.
echo AstrBot exited with code %ERRORLEVEL%.
pause
