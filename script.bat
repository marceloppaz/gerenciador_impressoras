@echo off
title Gerenciador remoto de impressoras

:: Verifica admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Solicitando permissao de administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

cd /d "%~dp0"

echo Iniciando Gerenciador...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0script.ps1"

echo.
echo Processo finalizado.
pause