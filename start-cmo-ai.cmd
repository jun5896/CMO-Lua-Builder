@echo off
rem CMO AI Bridge - AI 드라이버 선택 런처 (게임은 따로 실행; 브리지가 자동 감지)
title CMO AI Bridge
cd /d "%~dp0"
node tools\launch-ai-driver.mjs %*
if errorlevel 1 pause
