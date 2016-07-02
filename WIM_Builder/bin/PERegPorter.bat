set GetLastError=1
if /i "x%1" == "xLOAD" goto :REG_PORTER
if /i "x%1" == "xUNLOAD" (
  set "COMMENT_STR=) ^& rem ("
  goto :REG_PORTER
)

goto :EOF

:REG_PORTER
set GetLastError=0
set FILEPATH=X:\Windows\System32\config

(REG %1 HKLM\PE_DEFAULT %COMMENT_STR% %FILEPATH%\DEFAULT)
if ERRORLEVEL 1 set GetLastError=1

if "x%PB_REG_USE_SAM%"=="x1" (
  REG %1 HKLM\PE_SAM %COMMENT_STR% %FILEPATH%\SAM)
  if ERRORLEVEL 1 set GetLastError=1
)

if "x%PB_REG_USE_SECURITY%"=="x1" (
  (REG %1 HKLM\PE_SECURITY %COMMENT_STR% %FILEPATH%\SECURITY)
  if ERRORLEVEL 1 set GetLastError=1
)

(REG %1 HKLM\PE_SOFTWARE %COMMENT_STR% %FILEPATH%\SOFTWARE)
if ERRORLEVEL 1 set GetLastError=1
(REG %1 HKLM\PE_SYSTEM %COMMENT_STR% %FILEPATH%\SYSTEM)
if ERRORLEVEL 1 set GetLastError=1
(REG %1 HKLM\PE_NTUSER.DAT %COMMENT_STR% X:\Users\Default\NTUSER.DAT)
if ERRORLEVEL 1 set GetLastError=1

if /i "x%1" == "xLOAD" set PB_REG_LOADED=1
if /i "x%1" == "xUNLOAD" set PB_REG_LOADED=0

set FILEPATH=
set COMMENT_STR=

