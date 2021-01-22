@echo off

echo Prepare directories...
set script_dir=%~dp0
set src_dir=%script_dir%..
set build_dir=%script_dir%..\build
mkdir "%build_dir%"

echo Webview directory: %src_dir%
echo Build directory: %build_dir%

echo Looking for vswhere.exe...
set "vswhere=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%vswhere%" set "vswhere=%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%vswhere%" (
	echo ERROR: Failed to find vswhere.exe
	exit 1
)
echo Found %vswhere%

echo Looking for VC...
for /f "usebackq tokens=*" %%i in (`"%vswhere%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
  set vc_dir=%%i
)
if not exist "%vc_dir%\Common7\Tools\vsdevcmd.bat" (
	echo ERROR: Failed to find VC tools x86/x64
	exit 1
)
echo Found %vc_dir%


call "%vc_dir%\Common7\Tools\vsdevcmd.bat" -arch=x64 -host_arch=x64
echo Building webview.exe (x64)
cl /I "%src_dir%\script\microsoft.web.webview2.0.9.488\build\native\include" ^
	"%src_dir%\script\microsoft.web.webview2.0.9.488\build\native\x64\WebView2Loader.dll.lib" ^
	/I "%src_dir%" "%src_dir%/build/Debug/webview.lib" ^
    /std:c++17 /EHsc "/Fo%build_dir%"\ ^
	"%src_dir%\main.cc" /link "/OUT:%build_dir%\webview.exe" || exit \b

echo Building webview_test.exe (x64)
cl /I "%src_dir%\script\microsoft.web.webview2.0.9.488\build\native\include" ^
	"%src_dir%\script\microsoft.web.webview2.0.9.488\build\native\x64\WebView2Loader.dll.lib" ^
	/I "%src_dir%" "%src_dir%/build/Debug/webview.lib" ^
	/std:c++17 /EHsc "/Fo%build_dir%"\ ^
	"%src_dir%\webview_test.cc" /link "/OUT:%build_dir%\webview_test.exe" || exit \b
copy "%build_dir%/Debug/webview.lib" "%build_dir%/build"
