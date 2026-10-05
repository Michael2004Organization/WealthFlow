@echo off
rem Startet den WealthFlow-Server. Solange dieses Fenster offen ist, laeuft er.
rem Fenster schliessen beendet den Server. Es werden keine Windows-Einstellungen
rem veraendert; alle Daten liegen im Ordner "daten" neben dieser Datei.
chcp 65001 >nul
title WealthFlow-Server
cd /d "%~dp0"
"%~dp0bin\wealthflow_server.exe" --daten "%~dp0daten" %*
echo.
echo Der Server ist beendet.
pause
