@echo off
rem CMO AI Bridge - CMO 게임 + Claude Code 통합 런처
title CMO AI Bridge
cd /d "%~dp0"

rem 게임이 이미 떠 있으면 중복 실행하지 않는다 (본체 Command.exe / 런처 Launcher.exe 둘 다 확인)
tasklist /FI "IMAGENAME eq Command.exe" 2>nul | find /I "Command.exe" >nul
if not errorlevel 1 goto game_running
tasklist /FI "IMAGENAME eq Launcher.exe" 2>nul | find /I "Launcher.exe" >nul
if not errorlevel 1 goto game_running

echo [CMO AI Bridge] CMO를 Steam으로 실행합니다...
start "" "steam://rungameid/1076160"
goto claude

:game_running
echo [CMO AI Bridge] CMO가 이미 실행 중입니다.

:claude
echo [CMO AI Bridge] Claude Code를 시작합니다. 한국어로 지시하면 됩니다.
echo.
claude
