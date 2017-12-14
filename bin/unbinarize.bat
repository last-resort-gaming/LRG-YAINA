@ECHO OFF

REM Bring in settings
pushd %~dp0
call settings.bat
popd

set DIR=%~dp1
set FN=%~nx1

"%CFGCONVERT%" -txt -dst "%DIR%\%FN%.out" "%DIR%\%FN%"
move /y "%DIR%\%FN%.out" "%DIR%\%FN%"
