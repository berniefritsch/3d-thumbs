echo off
title Cleaner Routine
cls

REM TARGET DIRECTORY
set targetdir="F:\CLMN"

for /R %targetdir% %%F in (*.ply) do (
rem	if exist "%%~dpF\%%~nF.ply" del /s /q "%%~dpF\%%~nF.ply"
rem	if exist "%%~dpF\%%~nF.nxs" del /s /q "%%~dpF\%%~nF_temp.nxs"
rem	if exist "%%~dpF\%%~nF.nxs" del /s /q "%%~dpF\%%~nF.nxs"
rem	if exist "%%~dpF\%%~nFZ.nxs" del /s /q "%%~dpF\%%~nFZ.nxs"
	if exist "%%~dpF\%%~nF.png" del /s /q "%%~dpF\%%~nF.png"
	if exist "%%~dpF\%%~nFZ.png" del /s /q "%%~dpF\%%~nFZ.png"
)

if errorlevel 1 pause