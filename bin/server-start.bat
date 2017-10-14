@ECHO OFF

REM move to bin dir
pushd %~dp0

REM Bring in settings
call settings.bat

REM Kill Existing Servers
call server-kill.bat

REM Build PBO
call genPBO.bat

REM move up to server dir to make life easier
pushd ..\testing

REM Copy yaina.pbo to mpmissions of server and local cache so we don't have to download it
copy /y ..\..\yaina.Altis.pbo "%SERVER_DIR%\mpmissions"
copy /y ..\..\yaina.Altis.pbo "%MP_MISSIONS_CACHE_DIR%"

echo %SERVER% ^
	-ip=127.0.0.1 ^
	-name=server ^
	"-profiles=%cd%\Temp\server" ^
	-port=%PORT% ^
	"-config=%cd%\server.cfg" ^
	-world=empty ^
	-autoInit ^
	-loadMissionToMemory ^
	-mod=%MODS%

start "server" ^
	%SERVER% ^
	-ip=127.0.0.1 ^
	-name=server ^
	"-profiles=%cd%\Temp\server" ^
	-port=%PORT% ^
	"-config=%cd%\server.cfg" ^
	-world=empty ^
	-autoInit ^
	-loadMissionToMemory ^
	-mod=%MODS%
timeout /t 10

REM And pop back to start dir
popd
popd