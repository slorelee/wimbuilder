if "x%~2"=="x" goto :EOF
if not "x%~3"=="x" set %~3=

call PB_LOG "[%BUILD_PROJECT%] --- MOUNT [%~1:%PB_BASE_INDEX%] -%%gt:%% [%~2]"
if not exist "%~2" mkdir "%~2"
call DismX /mount-wim /wimfile:"%~1" /index:%PB_BASE_INDEX% /mountdir:"%~2"

if "x%~3"=="x" goto :EOF
if "%errorlevel%"=="0" set %~3=1
