@echo off
rem Detached launcher for AstrBot (spawned by the deployment; console redirected to logs).
cd /d "<WORKSPACE>\astrbot"
set PYTHONIOENCODING=utf-8
set PYTHONUTF8=1
set UV_CACHE_DIR=<WORKSPACE>\install\uv-cache
set UV_PYTHON_INSTALL_DIR=<WORKSPACE>\install\uv-python
if not exist logs mkdir logs
".venv\Scripts\python.exe" main.py >> "logs\stdout.log" 2>&1
