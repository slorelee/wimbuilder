@echo off
set GetLastError=0
if "x%~1"=="x\" (
  echo need directory path for %nx~0.
  set GetLastError=1
  goto :EOF
)

takeown /F "%~1" /A /R /D Y
if ERRORLEVEL 1 goto :ONERROR
icacls "%~1" /grant administrators:F /t
if ERRORLEVEL 1 goto :ONERROR
goto :EOF

:ON_ERROR
set GetLastError=1
