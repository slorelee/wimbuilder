set GetLastError=0
if "x%~1"=="x\" (
  echo need regfile path for %nx~0.
  set GetLastError=1
  goto :EOF
)
goto :EOF

:ON_ERROR
set GetLastError=1
