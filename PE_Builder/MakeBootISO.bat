@echo off

set PB_ISO_LABEL=BOOTPE
set PB_ISO_NAME=%PB_ISO_LABEL%

:LOAD_CONFIG
rem load config.ini
for /f "delims=" %%c in (config.ini) do %%c
if "x%PB_MNT_DIR%"=="x" (
  echo Please set the PB_MNT_DIR
  goto :ON_ERROR
)
if not exist "%PB_MNT_DIR%\build\boot_build.wim" (
  echo %PB_MNT_DIR%\build\boot_build.wim is not exist.
  goto :ON_ERROR
)

copy /y "%PB_MNT_DIR%\build\boot_build.wim" "%PB_MNT_DIR%\build\iso\sources\boot.wim"
"%~dp0\bin\oscdimg_x86.exe" -b"%PB_MNT_DIR%\build\iso\boot\etfsboot.com" -h -l"%PB_ISO_LABEL%" -m -u2 "%PB_MNT_DIR%\build\iso" "%PB_MNT_DIR%\build\%PB_ISO_NAME%.iso"
echo ISO:%PB_MNT_DIR%\build\%PB_ISO_NAME%.iso
If ERRORLEVEL 1 (
  echo make boot iso failed.
) else (
  echo make boot iso successfully.
)
pause
goto :EOF

:ON_ERROR
pause