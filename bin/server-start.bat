@ECHO OFF

REM move to bin dir
pushd %~dp0

REM Bring in settings
call settings.bat

REM Kill Existing Servers
call server-kill.bat

REM Build PBO
call genPBO.bat

REM move up to root dir to make life easier
pushd ..

REM Copy yaina.pbo to mpmissions of server and local cache so we don't have to download it
copy /y ..\yaina.Malden.pbo "%SERVER_DIR%\mpmissions"
copy /y ..\yaina.Malden.pbo "%MP_MISSIONS_CACHE_DIR%"

REM Copy keys
copy /y keys\* "%SERVER_DIR%\keys"

echo %SERVER% ^
	-ip=127.0.0.1 ^
	-name=server ^
	-nosplash ^
	"-profiles=%cd%\testing\server" ^
	-port=%PORT% ^
	"-config=%cd%\bin\server.cfg" ^
	-world=empty ^
	-autoInit ^
	-loadMissionToMemory ^
	-serverMods=%SERVER_MODS%

start "server" ^
	%SERVER% ^
	-ip=127.0.0.1 ^
	-name=server ^
    -nosplash ^
	"-profiles=%cd%\testing\server" ^
	-port=%PORT% ^
	"-config=%cd%\bin\server.cfg" ^
	-world=empty ^
	-autoInit ^
	-loadMissionToMemory ^
	-serverMods=%SERVER_MODS%
timeout /t 10

REM And pop back to start dir
popd
popd