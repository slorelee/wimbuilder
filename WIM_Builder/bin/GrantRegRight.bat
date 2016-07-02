@echo off
call :GRANT_REG_RIGHT HKLM\PE_DEFAULT
if not "%GetLastError%"=="0" goto :EOF

if "x%PB_REG_USE_SAM%"=="x1" (
  call :GRANT_REG_RIGHT HKLM\PE_SAM
  if not "%GetLastError%"=="0" goto :EOF
)

if "x%PB_REG_USE_SECURITY%"=="x1" (
  call :GRANT_REG_RIGHT HKLM\PE_SECURITY
  if not "%GetLastError%"=="0" goto :EOF
)

call :GRANT_REG_RIGHT HKLM\PE_SOFTWARE
if not "%GetLastError%"=="0" goto :EOF
call :GRANT_REG_RIGHT HKLM\PE_SYSTEM
if not "%GetLastError%"=="0" goto :EOF
call :GRANT_REG_RIGHT HKLM\PE_NTUSER.DAT
if not "%GetLastError%"=="0" goto :EOF
set GetLastError=0
set PB_URR_DONE=1
goto :EOF

:GRANT_REG_RIGHT
SetACL_x86.exe -on "%~1" -ot reg -actn setowner -ownr "n:Administrators" -rec yes 1>nul
if ERRORLEVEL 1 set GetLastError=1
if not "%GetLastError%"=="0" goto :EOF
SetACL_x86.exe -on "%~1" -ot reg -actn ace -ace "n:Administrators;p:full" -rec yes 1>nul
if ERRORLEVEL 1 set GetLastError=1
goto :EOF

