if "x%~1"=="x" goto :EOF
set GetLastError=1
if exist "%~dpn1_build%~x1" del /q "%~dpn1_build%~x1"
call PB_LOG "[%BUILD_PROJECT%] --- EXPORT [%~1:%PB_BASE_INDEX%] -%%gt:%% [%~dpn1_build%~x1]"

rem use imagex for building on Windows 7
ver|findstr " 6.1." >nul
if not ERRORLEVEL 1 (
  imagex_x86.exe /Export "%~1" %PB_BASE_INDEX% "%~dpn1_build%~x1" /boot
) else (
  call DismX /Export-Image /SourceImageFile:"%~1" /SourceIndex:%PB_BASE_INDEX% /DestinationImageFile:"%~dpn1_build%~x1" /Bootable
)
if "%errorlevel%"=="0" (
  del /q "%~1"
  set GetLastError=0
)
