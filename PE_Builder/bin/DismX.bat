ver|findstr " 10." >nul
if not ERRORLEVEL 1 (
  Dism.exe %*
  goto :EOF
)
"%~dp0Dism10_x86\Dism.exe" %*
