@echo OFF


REM Get Project Name (Dirname of parent folder)
for %%F in ("%~dp0..") do set projectName=%%~nxF

REM Move up to parent dir, then binaries
pushd %~dp0..

"%CFGCONVERT%" -bin -dst mission.sqm.bin mission.sqm
move /y mission.sqm.bin mission.sqm

REM Move to Output Dir
pushd ..

"%ADDONBUILDER%" "%cd%\%projectName%" "%cd%" -include="%~dp0genPBO-in.lst" -clear
REM copy %projectName%.pbo C:\Arma3Server\SteamFiles\mpmissions

REM back to mission dir
popd

REM UnBinarize
"%CFGCONVERT%" -txt -dst mission.sqm.txt mission.sqm
move /y mission.sqm.txt mission.sqm

REM Back to bin dir
popd
