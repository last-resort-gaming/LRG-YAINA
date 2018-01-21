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
copy /y client.Malden.pbo "%SERVER_DIR%\mpmissions\yaina.Malden.pbo"
copy /y client.Malden.pbo "%MP_MISSIONS_CACHE_DIR%\yaina.Malden.pbo"

REM Copy keys
copy /y keys\* "%SERVER_DIR%\keys"

REM Should substitute path
copy /y bin\A3Log-EU1.ini "%SERVER_DIR%\A3Log-EU1.ini"

REM Copy Be
mkdir "%cd%\Temp\server\battleye"
copy /y bin\beserver.cfg "Temp\server\battleye"
copy /y bin\beserver.cfg "Temp\server\battleye\beserver_x64.cfg"

REM Copy Server Config
mkdir "%cd%\Temp\server\Users"
mkdir "%cd%\Temp\server\Users\server"
copy /y bin\server.arma3profile "%cd%\Temp\server\Users\server\server.Arma3Profile"

echo %SERVER% ^
	-ip=127.0.0.1 ^
	-name=server ^
	-nosplash ^
	"-profiles=%cd%\Temp\server" ^
	-port=%PORT% ^
	"-config=%cd%\bin\server.cfg" ^
	-A3Log=A3Log-EU1.ini ^
	-world=empty ^
	-autoInit ^
	-loadMissionToMemory ^
	-serverMod=%SERVER_MODS%

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
	-loadMissionToMemory ^
	-serverMod=%SERVER_MODS%
timeout /t 10

REM And pop back to start dir
popd
popd