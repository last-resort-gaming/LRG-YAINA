@ECHO OFF

REM move to bin dir
pushd %~dp0

REM Bring in settings
call settings.bat

start "" "%SERVER_DIR%\arma3battleye.exe" 2 1 0 ^
	-malloc=tbb4malloc_bi_x64 ^
	-CpuCount=0 ^
	-ExThreads=7 ^
	-maxmem=8192 ^
	-maxVRAM=0 ^
    -skipintro ^
	-mod=%CLIENT_MODS% ^
	-noSplash ^
	-noFilePatching ^
	-world=empty ^
	-enableHT ^
	-showScriptErrors ^
	-connect=127.0.0.1 ^
	-port=%PORT%