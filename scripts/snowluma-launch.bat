@echo off
chcp 65001 >nul
title SnowLuma 2.2.0
rem ============================================================
rem  SnowLuma v2.2.0  (deployed at <SNOWLUMA_DIR>)
rem  WebUI:    http://127.0.0.1:5099   password: <REDACTED_PASSWORD>
rem  OneBot:   HTTP 3000 / WS 3001    reverse WS -> AstrBot 6199
rem ============================================================
rem  IMPORTANT: SnowLuma must run at Medium integrity so it can inject
rem  its hook into QQ.exe. Do NOT copy it into a DSH-sandboxed folder:
rem  files created by DSH carry a Low integrity label, which drops the
rem  node.exe process to Low and makes QQ hook injection impossible.
call "<SNOWLUMA_DIR>\Start-SnowLuma.bat"
