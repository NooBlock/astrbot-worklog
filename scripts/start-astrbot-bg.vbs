' Background launcher for AstrBot v4.29.3
' Runs start-astrbot.bat hidden (no console window) and returns immediately.
Set sh = CreateObject("WScript.Shell")
sh.CurrentDirectory = "<WORKSPACE>"
sh.Run "cmd /c ""<WORKSPACE>\start-astrbot.bat""", 0, False
