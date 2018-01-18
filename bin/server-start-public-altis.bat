@ECHO OFF

REM move to bin dir
pushd %~dp0

REM Bring in settings
call settings.bat

REM Kill Existing Servers
call server-kill.bat

REM Build PBO
call genPBO-altis.bat

REM move up to root dir to make life easier
pushd ..

REM Copy yaina.pbo to mpmissions of server and local cache so we don't have to download it
copy /y ..\yaina.Altis.pbo "%SERVER_DIR%\mpmissions"
copy /y ..\yaina.Altis.pbo "%MP_MISSIONS_CACHE_DIR%"

REM Copy keys
copy /y keys\* "%SERVER_DIR%\keys"

REM Copy Be
mkdir "%cd%\Temp\server\battleye"
copy /y bin\beserver.cfg "Temp\server\battleye"
copy /y bin\beserver.cfg "Temp\server\battleye\beserver_x64.cfg"

echo %SERVER% ^
	-name=server ^
	-nosplash ^
	-noSound ^
	"-profiles=%cd%\Temp\server" ^
	-port=%PORT% ^
	"-config=%cd%\bin\server-public-altis.cfg" ^
	-world=empty ^
	-autoInit ^
	-loadMissionToMemory ^
	"-BEpath=%cd%\Temp\server\battleye" ^
	-serverMod=%SERVER_MODS%

start "server" ^
	%SERVER% ^
	-name=server ^
    -nosplash ^
	-noSound ^
	"-profiles=%cd%\Temp\server" ^
	-port=%PORT% ^
	"-config=%cd%\bin\server-public-altis.cfg" ^
	-world=empty ^
	-autoInit ^
	-loadMissionToMemory ^
	"-BEpath=%cd%\Temp\server\battleye" ^
	-serverMod=%SERVER_MODS%
timeout /t 10

REM And pop back to start dir
popd
popd