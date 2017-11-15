@ECHO OFF

REM Bring in settings
call "%~dp0\settings.bat"

set DIR=%~dp1
set FN=%~nx1

"%CFGCONVERT%" -txt -dst "%DIR%\%FN%.out" "%DIR%\%FN%"
move /y "%DIR%\%FN%.out" "%DIR%\%FN%"
