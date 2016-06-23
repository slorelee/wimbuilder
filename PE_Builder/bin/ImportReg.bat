set GetLastError=0
if "x%~1"=="x" (
  echo need regfile path for %nx~0.
  set GetLastError=1
  goto :EOF
)

if not "x%PB_REG_LOADED%"=="x1" call PERegPorter.bat LOAD 1>nul
if not "%GetLastError%"=="0" goto :ON_ERROR
if "x%PB_SKIP_URR%"=="x1" goto :REG_IMPORT

if "x%PB_URR_DONE%"=="x1" goto :REG_IMPORT
call GrantRegRight.bat
if not "%GetLastError%"=="0" goto :ON_ERROR

:REG_IMPORT
if /i "x%~1"=="x[LOAD-TRIGGER]" goto :EOF

for /f "delims=" %%r in ('dir /b "%~1\*.reg"') do (
  cscript.exe //nologo %~dp0PERegProcessor.vbs "%~1\%%~r"
  reg import "%~1\%%~r_"
  if ERRORLEVEL 1 set GetLastError=1
)

del /q "%~1\*.reg_"
goto :EOF

:ON_ERROR
set GetLastError=1
