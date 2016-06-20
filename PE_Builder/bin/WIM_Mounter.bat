if "x%~2"=="x" goto :EOF
if not "x%~3"=="x" set %~3=

call PB_LOG "[%BUILD_PROJECT%] --- MOUNT [%~1] -%%gt:%% [%~2]"
if not exist "%~2" mkdir "%~2"
call DismX /mount-wim /wimfile:"%~1" /index:1 /mountdir:"%~2"

if "x%~3"=="x" goto :EOF
if "%errorlevel%"=="0" set %~3=1
