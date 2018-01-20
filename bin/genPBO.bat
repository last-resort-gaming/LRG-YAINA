@echo OFF


REM Get Project Name (Dirname of parent folder)
for %%F in ("%~dp0..") do set projectName=%%~nxF

REM Move up to parent dir, then binaries
pushd ..
pushd client

"%CFGCONVERT%" -bin -dst mission.sqm.bin mission.sqm
move /y mission.sqm.bin mission.sqm

REM Move to Output Dir
popd

echo %cd%

"%ADDONBUILDER%" "%cd%\client" "%cd%" -include="%~dp0genPBO-in.lst" -clear
REM copy %projectName%.pbo C:\Arma3Server\SteamFiles\mpmissions

pushd client

REM UnBinarize
"%CFGCONVERT%" -txt -dst mission.sqm.txt mission.sqm
move /y mission.sqm.txt mission.sqm

REM Back to base dir
popd

REM Back to bin dir
popd

echo %cd%
pause