@echo off
setlocal
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0start-cmo-lua-ui.ps1" -Silent
endlocal
exit /b 0
