@echo off
powershell -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoExit', '-NoProfile', '-ExecutionPolicy Bypass', '-File %~dp0script\win10-setup-script.ps1'" 