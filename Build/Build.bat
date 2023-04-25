echo off
title Building Routine
cls

REM FILES DIRECTORIES
set targetdir="C:\Users\bfritsch\Documents\SfM\ScriptThumbs\Build\"
set builddir="C:\Users\bfritsch\Documents\SfM\ScriptThumbs\Build\Athen"
set filterdir="C:\Users\bfritsch\Documents\SfM\ScriptThumbs\Filters"

REM FILTER NAME
set filtername=xyz.mlx

REM PROGRAMS DIRECTORIES
set meshlabdir="C:\Program Files\VCG\MeshLab"
set nexusdir="C:\Users\bfritsch\Documents\SfM\Nexus_4.3"
set screenshotcmddir="C:\Users\bfritsch\Documents\SfM\ScriptThumbs"
set imagemagickdir="C:\Program Files\ImageMagick-7.1.1-Q16-HDRI"

REM SCREENSHOT SETUP
set screen_width=2560
set screen_height=1600
set screenshot_width=800
set screenshot_height=800
set thumbnail_width=400
set thumbnail_height=400

echo Script Log File >%cd%\Buildlog.txt

set /a "x=((screen_width/2)-(screenshot_width/2)-90)"
set /a "y=((screen_height/2)-(screenshot_height/2)-40)"
set /a "w=(x+screenshot_width)"
set /a "h=(y+screenshot_height)"

set tempdir="C:\Windows\Temp\Nxs.tmp"
if exist "%tempdir%" (
	del /s /q "%tempdir%\*.*"
) else md "%tempdir%"
start "" /b /max /d %nexusdir% nxsview.exe "build.nxs"
timeout 2 >nul
start "" /b /wait /d %screenshotcmddir% screenshot-cmd.exe -wt "NxsView - ISTI-CNR" -rc %x% %y% %w% %h% -o "%tempdir%\background.png"
taskkill /im nxsview.exe  >nul

for /R %targetdir% %%F in (*.ply) do (
	echo. >>%cd%\Buildlog.txt
	echo %%F >>%cd%\Buildlog.txt
 echo PLY 2 PLY: Apply MeshLab Filter >>%cd%\Buildlog.txt
	start "" /b /wait /d %meshlabdir% meshlabserver.exe -i "%%F" -o "%%~dpF\%%~nF.ply" -m vn vc -s "%filterdir%\%filtername%"  >>%cd%\Buildlog.txt
 echo PLY 2 NXS: Build Nexus File >>%cd%\Buildlog.txt
	start "" /b /wait /d %nexusdir% nxsbuild.exe "%%~dpF\%%~nF.ply" -o "%%~dpF\%%~nF_temp.nxs" >>%cd%\Buildlog.txt
	start "" /b /wait /d %nexusdir% nxsedit.exe "%%~dpF\%%~nF_temp.nxs" -z -o "%%~dpF\%%~nF.nxs" >>%cd%\Buildlog.txt
 echo Removing NXS temp uncopressed files >>%cd%\Buildlog.txt
	del /s /q "%%~dpF\%%~nF_temp.nxs" >>%cd%\Buildlog.txt
echo NXS 2 PNG: Take Nexus Screenshot >>%cd%\Buildlog.txt
	if exist "%%~dpF\%%~nF.nxs" (
		start "" /b /max /d %nexusdir% nxsview.exe "%%~dpF\%%~nF.nxs"
		timeout 2 >nul
		start "" /b /wait /d %screenshotcmddir% screenshot-cmd.exe -wt "NxsView - ISTI-CNR" -rc %x% %y% %w% %h% -o "%tempdir%\%%~nF.png"
 if exist "%%~dpF\%%~nF.png" del /s /q "%%~dpF\%%~nF.png"	
		start "" /b /wait /d %imagemagickdir% convert "%tempdir%\%%~nF.png" "%tempdir%\background.png" -compose ChangeMask -composite "%%~dpF\%%~nF.png"
		copy "%%~dpF\%%~nF.png" "%builddir%\%%~nF.png"
		start "" /b /wait /d %imagemagickdir% mogrify -resize %thumbnail_width%x%thumbnail_height% "%%~dpF\%%~nF.png"
		taskkill /im nxsview.exe  >nul
		del /s /q "%tempdir%\%%~nF.png"
	)
 echo.
)

del /s /q "%nexusdir%\build.nxs"
rd /s /q "%tempdir%"
if errorlevel 1 pause

