@echo off
call :GRANT_REG_RIGHT HKEY_LOCAL_MACHINE\PE_SOFT\Classes
call :GRANT_REG_RIGHT HKEY_LOCAL_MACHINE\PE_SOFT\Microsoft\Ole\Extensions
call :GRANT_REG_RIGHT HKEY_LOCAL_MACHINE\PE_SOFT\Microsoft\WindowsRuntime
goto :EOF

:GRANT_REG_RIGHT
SetACL_x86.exe -on "%~1" -ot reg -actn setowner -ownr "n:Administrators" -rec yes 1>nul
SetACL_x86.exe -on "%~1" -ot reg -actn ace -ace "n:Administrators;p:full" -rec yes 1>nul
goto :EOF

