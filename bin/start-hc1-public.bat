@ECHO OFF

REM move to bin dir
pushd %~dp0

REM Bring in settings
call settings.bat

REM move up to  root dir to make life easier
pushd ..

start "HC_1" ^
	%SERVER% ^
	"-profiles=%cd%\testing\HC_1" ^
	-nosplash ^
	-client ^
	-noSound ^
	-connect=127.0.0.1 ^
	-port=%PORT% ^
	-mod=%MODS% ^
	-password="LRG"

popd