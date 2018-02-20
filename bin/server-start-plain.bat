
REM move to bin dir
pushd %~dp0

REM Bring in settings
call settings.bat

REM move up to root dir to make life easier
pushd ..

start "server" ^
	%SERVER% ^
	-ip=127.0.0.1 ^
	-name=server ^
    -nosplash ^
	"-profiles=%cd%\Temp\server" ^
	-port=%PORT% ^
	"-config=%cd%\bin\server.cfg" ^
	-A3Log=A3Log-EU1.ini ^
	-world=empty ^
	-autoInit ^
	-instanceName=EU1 ^
	-loadMissionToMemory ^
	-serverMod=%SERVER_MODS%