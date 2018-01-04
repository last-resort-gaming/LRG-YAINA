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

REM Copy Be
mkdir "%cd%\testing\server\battleye"
copy /y bin\beserver.cfg "testing\server\battleye"
copy /y bin\beserver.cfg "testing\server\battleye\beserver_x64.cfg"

echo %SERVER% ^
	-name=server ^
	-nosplash ^
	-noSound ^
	"-profiles=%cd%\testing\server" ^
	-port=%PORT% ^
	"-config=%cd%\bin\server-public.cfg" ^
	-world=empty ^
	-autoInit ^
	-loadMissionToMemory ^
	"-BEpath=%cd%\testing\server\battleye" ^
	-serverMod=%SERVER_MODS%

start "server" ^
	%SERVER% ^
	-name=server ^
    -nosplash ^
	-noSound ^
	"-profiles=%cd%\testing\server" ^
	-port=%PORT% ^
	"-config=%cd%\bin\server-public.cfg" ^
	-world=empty ^
	-autoInit ^
	-loadMissionToMemory ^
	"-BEpath=%cd%\testing\server\battleye" ^
	-serverMod=%SERVER_MODS%
timeout /t 10

REM And pop back to start dir
popd
popd