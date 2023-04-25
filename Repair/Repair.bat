echo off
title Repairing Routine
cls

REM FILES DIRECTORIES
set targetdir="F:\Build\ReposBSYP"
set repairdir="F:\Script\Repair"
set filterdir="F:\Script\Filters"

REM FILTER NAME
set filtername=rotate_x_90

REM PROGRAMS DIRECTORIES
set meshlabdir="F:\MeshLab"
set nexusdir="F:\Nexus_4.0"
set screenshotcmddir="F:\Screenshot-cmd"
set imagemagickdir="F:\Program Files\ImageMagick-6.9.3-Q16"

REM SCREENSHOT SETUP
set screen_width=2560
set screen_height=1600
set screenshot_width=800
set screenshot_height=800
set thumbnail_width=400
set thumbnail_height=400

echo Script Log File >%cd%\Repairlog.txt

set /a "x=((screen_width/2)-(screenshot_width/2)-90)"
set /a "y=((screen_height/2)-(screenshot_height/2)-40)"
set /a "w=(x+screenshot_width)"
set /a "h=(y+screenshot_height)"

set tempdir="C:\Windows\Temp\Nxs.tmp"
if exist "%tempdir%" (
	del /s /q "%tempdir%\*.*"
) else md "%tempdir%"
start "" /b /max /d %nexusdir% nxsview.exe "repair.nxs"
timeout 2 >nul
start "" /b /wait /d %screenshotcmddir% screenshot-cmd.exe -wt "NxsView - ISTI-CNR" -rc %x% %y% %w% %h% -o "%tempdir%\background.png"
taskkill /im nxsview.exe  >nul

for %%P in (*.png) do (
	echo test >>%cd%\Repairlog.txt
	echo|set /p= %%~nP
	call :inner
)
goto :end

:inner
for /R %targetdir% %%F in (*.ply) do (
	if "%%~nF"=="%%~nP" (
		echo.
		echo. >>%cd%\Repairlog.txt
		echo %%F >>%cd%\Repairlog.txt
 echo PLY 2 PLY: Apply MeshLab Filter >>%cd%\Repairlog.txt
		start "" /b /wait /d %meshlabdir% meshlabserver.exe -i "%%F" -o "%%F" -s "%filterdir%\%filtername%" -om vn vc >>%cd%\Repairlog.txt
 echo PLY 2 NXS: Build Nexus File >>%cd%\Repairlog.txt
		start "" /b /wait /d %nexusdir% nxsbuild.exe "%%F" -c -o "%%~dpF\%%~nF_temp.nxs" >>%cd%\Repairlog.txt
		start "" /b /wait /d %nexusdir% nxsedit.exe "%%~dpF\%%~nF_temp.nxs" -z -o "%%~dpF\%%~nF.nxs" >>%cd%\Repairlog.txt
 echo Removing NXS temp uncopressed files >>%cd%\Repairlog.txt
		del /s /q "%%~dpF\%%~nF_temp.nxs" >>%cd%\Repairlog.txt
 echo NXS 2 PNG: Take Nexus Screenshot >>%cd%\Repairlog.txt
		if exist "%%~dpF\%%~nF.nxs" (
			start "" /b /max /d %nexusdir% nxsview.exe "%%~dpF\%%~nF.nxs"
			timeout 2 >nul
			start "" /b /wait /d %screenshotcmddir% screenshot-cmd.exe -wt "NxsView - ISTI-CNR" -rc %x% %y% %w% %h% -o "%tempdir%\%%~nF.png"
if exist "%%~dpF\%%~nF.png" del /s /q "%%~dpF\%%~nF.png"			
			start "" /b /wait /d %imagemagickdir% convert "%tempdir%\%%~nF.png" "%tempdir%\background.png" -compose ChangeMask -composite "%%~dpF\%%~nF.png"
			copy "%%~dpF\%%~nF.png" "%repairdir%\%%~nF.png"
			start "" /b /wait /d %imagemagickdir% mogrify -resize %thumbnail_width%x%thumbnail_height% "%%~dpF\%%~nF.png"
			taskkill /im nxsview.exe  >nul
			del /s /q "%tempdir%\%%~nF.png"
		)
		echo.
		exit /B 2
	) else ( echo|set /p=.)
)

:end
echo.
del /s /q "%nexusdir%\repair.nxs"
rd /s /q "%tempdir%"
if errorlevel 1 pause

