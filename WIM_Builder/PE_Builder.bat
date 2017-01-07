@echo off
rem Copyleft 2006 by slore, everyone can use, edit, and redistribute those scripts
rem WITHOUT ANY LIMITATIONS
SETLOCAL ENABLEDELAYEDEXPANSION
cd /d "%~dp0"
title PE Builder(%cd%)

rem run with Administrators right
bin\IsAdmin_x86.exe
if not ERRORLEVEL 1 (
  if "x%~1"=="x" (
    set ElevateMe=1
    bin\ElevateMe.vbs "%~0" "runas"
    goto :EOF
  )
)

 if "%~1"=="PB_APPLY_PACKAGE" (
  call :PB_APPLY_PACKAGE "%~2"
  goto :EOF
)

 if "%~1"=="PB_APPLY_PATCH" (
  call :PB_APPLY_PATCH "%~2"
  goto :EOF
)

rem init i18n file
set "I18N_SCRIPT=%~dp0i18n\i18n_.wsf"
for /f "delims=" %%i in ('cscript.exe //nologo "%I18N_SCRIPT%" init') do set LocaleID=%%i
if "x%LocaleID%"=="x" set LocaleID=0
set I18N_LCID=%LocaleID%
if not exist i18n\%LocaleID%.vbs (
    set I18N_LCID=0
    goto :LOAD_CONFIG
)

set "I18N_SCRIPT=%~dp0i18n\i18n.wsf"
if not exist i18n\0.vbs goto :UPDATE_I18NRES
fc /b i18n\%LocaleID%.vbs i18n\0.vbs>nul
if not ERRORLEVEL 1 goto :LOAD_CONFIG

:UPDATE_I18NRES
copy /y i18n\%LocaleID%.vbs i18n\0.vbs

:LOAD_CONFIG
rem load config.ini
for /f "delims=" %%c in (config.ini) do call %%c

if not "x%ElevateMe%"=="x1" (
  if not "x%~1"=="x" (
    set BUILD_PROJECT=%1
  )
)

:SELECT_PROJECT
rem select build project
cls
echo.
echo                                    \033[97;104mWinPE \033[97;105mBuilder \033[94;102mv1.0 | bin\CmdColor_x86.exe

call :techo Projects:
set i=0
for /f "delims=" %%p in ('dir /b /ad ..\Projects') do (
  set /a i+=1
  set PJ_!i!=%%p
  echo     !i!.%%p
)
echo.
call :setp nPJ "Please select the project[1/2/.../n]:"
if "x!PJ_%nPJ%!"=="x" goto :SELECT_PROJECT
echo.
set BUILD_PROJECT=!PJ_%nPJ%!

set SYS_PATH=%Path%
set Path=%~dp0bin;%Path%

rem generate logfile name
rem ">" mark will cause *ECHO* error, change to "*"
rem i.e. Mount [WIM] -> [PATH] ---> Mount [WIM] -* [PATH]
rem set gt:=^^^>
set gt:=*
for /f "delims=" %%t in ('cscript.exe //nologo bin\TimeStamp.vbs') do set LOGSUFFIX=%%t
set "LOGFILE=%~dp0log\%BUILD_PROJECT%_%LOGSUFFIX%.log"
rem type nul>%LOGFILE%

pushd ..\Projects\%BUILD_PROJECT%

rem load project config.ini
if exist config.ini (
  for /f "delims=" %%c in (config.ini) do call %%c
)

rem ";" cann't be pass to CALL LABEL, so use a ":" for it
call :CLOG 97:104m "[%BUILD_PROJECT%] --- build information"
set PB_
echo.

if not "x%PB_CLEANUP_MODE%"=="x" (
  if not "x%PB_SRC_WIM%"=="x" set src_wim_mounted=1
  if not "x%PB_BASE_WIM%"=="x" set base_wim_mounted=1
  rem goto :PROJECT_BUILDING
  call :CLEANUP
  pause
  exit 0
)

call :cecho PHRASE "PHRASE:Get WIM image INFO"
for /f "tokens=1,2 delims=:(" %%i in ('DismX.bat /Get-WimInfo /WimFile:"%PB_BASE_WIM%" /Index:%PB_BASE_INDEX% /English') do (
  if "%%i"=="Architecture " set PB_PE_ARCH=%%j
  if "%%i"=="Version " set PB_PE_VER=%%j
  if "%%i"=="ServicePack Build " set PB_PE_BUIID=%%j
  if "x!LANG_FLAG!"=="x1" (
    set PB_PE_LANG=%%i
    set LANG_FLAG=
  )
  if "%%i"=="Languages " set LANG_FLAG=1
)

if "x%PB_PE_LANG%"=="x" (
    call :cecho ERROR "Get WIM image's information failed."
    pause
    goto :EOF
)

set "PB_PE_ARCH=%PB_PE_ARCH: =%"
set "PB_PE_VER=%PB_PE_VER: =%"
set "PB_PE_BUIID=%PB_PE_BUIID: =%"
rem here is TAB, not SPACE 
set "PB_PE_LANG=%PB_PE_LANG:	=%"
set "PB_PE_LANG=%PB_PE_LANG: =%"

set PB_PE_
echo.
call :cecho PHRASE "PHRASE:Mount WIM image"
if "x%PB_STRAIGHT_MODE%"=="x" pause

rem check X: driver
if exist X:\ (
  call :cecho WARN "X: is already use."
  call :setp yTry "Try SUBST X: /D?[y/n]:"
)
if "%yTry%"=="y" SUBST X: /D
if "%yTry%"=="Y" SUBST X: /D
if exist X:\ (
  call :cecho ERROR "X: is already in use, goto CLEANUP."
  if "x%PB_STRAIGHT_MODE%"=="x" pause
  call :CLEANUP
)

rem PHRASE:mount WIM
if "x%PB_BASE_INDEX%"=="x" set PB_BASE_INDEX=1
if "x%PB_SRC_INDEX%"=="x" set PB_SRC_INDEX=1
if "x%PB_MNT_DIR%"=="x" call :NO_ENV_CONF PB_MNT_DIR
if not exist "%PB_MNT_DIR%" call :PB_ERROR "Please make the mount dir %PB_MNT_DIR%"
if not "x%PB_SRC_WIM%"=="x" (
  call WIM_Mounter.bat "%PB_SRC_WIM%" %PB_SRC_INDEX% "%PB_MNT_DIR%\SOURCES" src_wim_mounted
  goto :CHECK_SRC_MOUNT
)

goto :BASE_MOUNT
:CHECK_SRC_MOUNT
if not "%src_wim_mounted%"=="1" (
  call :cecho ERROR "mount source wim file failed."
  call :CLEANUP
)

:BASE_MOUNT
if "x%PB_BASE_WIM%"=="x" call :NO_ENV_CONF PB_BASE_WIM
if "x%PB_PE_WIM%"=="x" call :NO_ENV_CONF PB_PE_WIM

call :MKPATH "%PB_PE_WIM%"
call copy /y "%PB_BASE_WIM%" "%PB_PE_WIM%"

call WIM_Mounter.bat "%PB_PE_WIM%" %PB_BASE_INDEX% "%PB_MNT_DIR%\%BUILD_PROJECT%" base_wim_mounted
if not "%base_wim_mounted%"=="1" (
  call :cecho ERROR "mount base wim file failed."
  call :CLEANUP
)

rem NOTICE:explorer.exe don't show X:\ when running with Administrators right
SUBST X: "%PB_MNT_DIR%\%BUILD_PROJECT%"
echo.
if "x%PB_SKIP_UFR%"=="x1" goto :PROJECT_BUILDING
rem update files ACL Right
call :cecho PHRASE "PHRASE:updating files' ACL rights"
if "x%PB_STRAIGHT_MODE%"=="x" pause
call :techo "Updating...(Please, be patient)"
call TrustedInstallerRight.bat "%PB_MNT_DIR%\%BUILD_PROJECT%" 1>nul
if not "%GetLastError%"=="0" call :CLEANUP
call :techo "Update files with Administrators' FULL ACL rights successfully."
echo.
:PROJECT_BUILDING
call :cecho PHRASE "PHRASE:Going PE Building process(DEL, ADD, REG)"
if "x%PB_STRAIGHT_MODE%"=="x" pause
set PROCESS_PROJECT=1
call :PB_PROCESS .
for /f "delims=" %%s in ('dir /b /ad .') do (
  if not "x%%s"=="xX" (
    call :PB_APPLY_PATCH %%s
  )
)

popd

echo.
call :cecho PHRASE "PHRASE:Commit modification and build the WIM"
if "x%PB_STRAIGHT_MODE%"=="x" pause
call :CLEANUP 0
call WIM_Exporter.bat "%PB_PE_WIM%"
if not "%GetLastError%"=="0" goto :ERROR_EXPORT
echo.
call :cecho PHRASE "PHRASE:build bootable ISO file"
if "x%PB_STRAIGHT_MODE%"=="x" pause
call MakeBootISO.bat
goto :EOF

:ERROR_EXPORT
call :cecho ERROR "Export build WIM failed."
pause
goto :EOF

rem =========================================================
:PB_APPLY_PACKAGE
if "x%~1"=="x" goto :EOF
if not "%PROCESS_PROJECT%"=="1" goto :EOF
echo APPLYING-PACKAGE:%1
if "x%PB_STRAIGHT_MODE%"=="x" pause
pushd "%~1"
call :PB_PROCESS "%~1"
for /f "delims=" %%s in ('dir /b /ad "%~1"') do (
  if not "x%%s"=="xX" (
    call :PB_APPLY_PATCH %%s
  )
)
popd
goto :EOF

:PB_APPLY_PATCH
echo APPLYING-PATCH:%1
if "x%PB_STRAIGHT_MODE%"=="x" pause
call :PB_PROCESS "%~1"
goto :EOF

:PB_PROCESS
if "x%~1"=="x" goto :EOF
if not "%PROCESS_PROJECT%"=="1" goto :EOF

rem PROCESS:INIT
if exist "%~1\INIT.bat" (
  call "%~1\INIT.bat"
)

rem PROCESS:delete file
set TMP_SKIP_FLAG=1
if exist "%~1\KEEP_ITEMS.txt" set TMP_SKIP_FLAG=0
if exist "%~1\DEL_DIRS.txt" set TMP_SKIP_FLAG=0
if exist "%~1\DEL_FILES.txt" set TMP_SKIP_FLAG=0
if %TMP_SKIP_FLAG% EQU 1 goto :DEAL_ADD_FILES

call :techo "PROCESS:delete files"

if not exist "%~1\KEEP_ITEMS.txt" goto :DEAL_DEL_DIRS
if exist "X:\[KEEP_ITEMS]" rd /s /q "X:\[KEEP_ITEMS]"

for /f "eol=; delims=" %%f in (%~1\KEEP_ITEMS.txt) do (
  set "KEEP_PATH=%%~f"
  goto :DEAL_KEEP_ITEMS_EX
)

:DEAL_KEEP_ITEMS_EX
set KIN_SCRIPT=KeepItemsName.vbs
set KEEP_ITEMS_FILE=KEEP_ITEMS.txt
if /i "x%KEEP_PATH%"=="xWindows\WinSxS" set KIN_SCRIPT=KeepItemsNameEx.vbs
if /i "x%KEEP_PATH%"=="xWindows\System32\CatRoot" set KIN_SCRIPT=KeepItemsNameEx.vbs
if not "x%KIN_SCRIPT%"=="xKeepItemsNameEx.vbs" goto :DEAL_KEEP_ITEMS

set KEEP_ITEMS_FILE=KEEP_ITEMS_EX.txt
set KEEP_PATH=%KEEP_PATH%\
(echo %KEEP_PATH%)>"%~1\KEEP_ITEMS_EX.txt"
for /f "eol=; skip=1 delims=" %%f in (%~1\KEEP_ITEMS.txt) do (
  if /i "%%f"=="+Manifests" (
    (echo %%f)>>"%~1\KEEP_ITEMS_EX.txt"
  ) else (
    call :CREATE_ITEMS_EX "%%~f" "%~1\KEEP_ITEMS_EX.txt"
  )
)

goto :DEAL_KEEP_ITEMS

:CREATE_ITEMS_EX
set "KEEP_FILE_NAME=%~1"
if "x%KEEP_FILE_NAME:~0, 1%"=="x=" (
  (echo %~1)>>"%~2"
) else (
  call dir /b "X:\%KEEP_PATH%%~1" >>"%~2"
)
set KEEP_FILE_NAME=
goto :EOF

:DEAL_KEEP_ITEMS
for /f "delims=" %%f in ('cscript.exe //nologo %~dp0bin\%KIN_SCRIPT% "%~1\%KEEP_ITEMS_FILE%"') do (
  call xcopy /Q /H /K /Y %%f 1>nul
)
rem if exist "%~1\KEEP_ITEMS_EX.txt" del /q "%~1\KEEP_ITEMS_EX.txt"
set KEEP_ITEMS_FILE=
set KIN_SCRIPT=

rd /s /q "X:\%KEEP_PATH%"
xcopy /S /E /Q /H /K /Y "X:\[KEEP_ITEMS]" "X:\%KEEP_PATH%"
rd /s /q "X:\[KEEP_ITEMS]"
set KEEP_PATH=

:DEAL_DEL_DIRS
if exist "%~1\DEL_DIRS.txt" (
  for /f "eol=; delims=" %%f in (%~1\DEL_DIRS.txt) do call rd /s /q "X:\%%~f" 1>nul
)
if exist "%~1\DEL_FILES.txt" (
  for /f "eol=; delims=" %%f in (%~1\DEL_FILES.txt) do call del /f /q "X:\%%~f" 1>nul
)

:DEAL_ADD_FILES
rem PROCESS:add files
set TMP_SKIP_FLAG=1
if exist "%~1\ADD_ITEMS.txt" set TMP_SKIP_FLAG=0
if exist "%~1\X" set TMP_SKIP_FLAG=0
if %TMP_SKIP_FLAG% EQU 1 goto :DEAL_REG_FILES

call :techo "PROCESS:add files"
if not exist "%~1\ADD_ITEMS.txt" goto :DEAL_X_DIR
for /f "delims=" %%f in ('cscript.exe //nologo %~dp0bin\AddItemsName.vbs "%~1\ADD_ITEMS.txt" "%PB_MNT_DIR%\SOURCES\"') do (
  call xcopy /Q /H /K /Y %%f 1>nul
)

:DEAL_X_DIR
if exist "%~1\X" (
  xcopy /E /Q /H /K /Y "%~1\X\*" X:\
)

:DEAL_REG_FILES
rem PROCESS:import reg files
set TMP_SKIP_FLAG=1
dir /b "%~1\*.reg" 1>nul 2>nul
if not ERRORLEVEL 1 set TMP_SKIP_FLAG=0
if %TMP_SKIP_FLAG% EQU 1 goto :DEAL_LAST

call :techo "PROCESS:update registry"
call ImportReg.bat "%~1"

:DEAL_LAST
rem PROCESS:LAST
if exist "%~1\LAST.bat" (
  call "%~1\LAST.bat"
)

goto :EOF

rem =========================================================

:MKPATH
if not exist "%~dp1" mkdir "%~dp1"
goto :EOF

rem =========================================================
:i18n.t
if not "x%DEBUG_MODE%"=="x" echo %*
set i18n.str=
set i18n.log=
if "%I18N_LCID%"=="0" (
  if /i "x%~1"=="xECHO" (
    if "x%~3"=="x" (
      set "i18n.str=%~2"
      goto :EOF
    )
  )
)

set tmp_i=1
for /f "delims=" %%s in ('cscript.exe //nologo "%I18N_SCRIPT%" %*') do (
  set "i18n.str!tmp_i!=%%s"
  set /a tmp_i+=1
)
set tmp_i=
set "i18n.str=%i18n.str1%"
set "i18n.log=%i18n.str2%"
goto :EOF

:techo
call :i18n.t ECHO %*
echo %i18n.str%
goto :EOF

:setp
call :i18n.t SETP_%*
set /p %1=%i18n.str%
set p1=
goto :EOF

:cecho
call :i18n.t CLR_%*
echo %i18n.str% | cmdcolor_x86.exe
goto :EOF

:LOG
call :i18n.t LOG %*
echo %i18n.str%
>>%LOGFILE% (echo %i18n.log%)
goto :EOF

:CLOG
call :i18n.t CLR_LOG_%*
echo %i18n.str% | cmdcolor_x86.exe
>>%LOGFILE% (echo %i18n.log%)
goto :EOF

rem =========================================================
:PB_ERROR
call :CLOG ERROR %*
call :CLEANUP

:NO_ENV_CONF
call :CLOG ERROR "Please specify the @s in config.ini" %1
call :CLEANUP

:CLEANUP
if "x%PB_REG_LOADED%"=="x1" call PERegPorter.bat UNLOAD 1>nul

if not "x%src_wim_mounted%"=="x" (
    call WIM_UnMounter.bat "%PB_MNT_DIR%\SOURCES" /discard src_wim_mounted
)
set UNMNT_OPT=/discard
if "x%1"=="x0" (
  rem cleanup REGISTRY log files
  del /f /q /a X:Windows\System32\config\*.LOG* 1>nul 2>nul
  del /f /q /a X:Windows\System32\config\*{*}* 1>nul 2>nul
  del /f /q /a X:Windows\System32\SMI\Store\Machine\*.LOG* 1>nul 2>nul
  del /f /q /a X:Windows\System32\SMI\Store\Machine\*{*}* 1>nul 2>nul
  set UNMNT_OPT=/commit
)
if not "x%base_wim_mounted%"=="x" (
  call WIM_UnMounter.bat "%PB_MNT_DIR%\%BUILD_PROJECT%" %UNMNT_OPT% base_wim_mounted
)

if exist X:\ SUBST X: /D

if "x%1"=="x0" (
  goto :EOF
)
pause
exit 1
