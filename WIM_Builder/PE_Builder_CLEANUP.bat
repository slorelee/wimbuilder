@echo off
cd /d "%~dp0"

set PB_CLEANUP_MODE=TRUE
set PB_REG_LOADED=1

rem run with Administrators right
bin\IsAdmin_x86.exe
if not ERRORLEVEL 1 (
  if "x%~1"=="x" (
    set ElevateMe=1
    bin\ElevateMe.vbs "%~0" "runas"
    goto :EOF
  )
)

PE_Builder.bat