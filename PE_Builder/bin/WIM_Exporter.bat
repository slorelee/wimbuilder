if "x%~1"=="x" goto :EOF
set GetLastError=1
if exist "%~dpn1_build%~x1" del /q "%~dpn1_build%~x1"
call PB_LOG "[%BUILD_PROJECT%] --- EXPORT [%~1] -%%gt:%% [%~dpn1_build%~x1]"
call DismX /Export-Image /SourceImageFile:"%~1" /SourceIndex:1 /DestinationImageFile:"%~dpn1_build%~x1" /Bootable
if "%errorlevel%"=="0" (
  del /q "%~1"
  set GetLastError=0
)
