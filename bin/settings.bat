@ECHO OFF

set MP_MISSIONS_CACHE_DIR=C:\Users\Martin\AppData\Local\Arma 3\MPMissionsCache
set SERVER_DIR=C:\Program Files (x86)\Steam\steamapps\common\Arma 3
set SERVER_MODS="!Workshop\@Advanced Rappelling;!Workshop\@Advanced Sling Loading;!Workshop\@Advanced Towing;!Workshop\@Advanced Urban Rappelling" 
@REM ;D:\Arma3BRC\BRC_HELPER\ARMA 3\@brc_helper"
set CLIENT_MODS="!Workshop\@CBA_A3;!Workshop\@Blastcore Edited (standalone version);!Workshop\@Enhanced Movement;!Workshop\@Enhanced Soundscape;!Workshop\@DynaSound 2;!Workshop\@ShackTac User Interface;!Workshop\@Ares Mod - Achilles Expansion;!Workshop\@ZEC - Zeus and Eden Templates - Building Compositions"
set MODS="curator;kart;heli;mark;expansion;dlcbundle;jets;dlcbundle2;"
set SERVER="%SERVER_DIR%\arma3server_x64.exe"
set PORT=2502
set TOOLSDIR="C:\Program Files (x86)\Steam\steamapps\common\Arma 3 Tools"
set ADDONBUILDER="%TOOLSDIR%\AddonBuilder\AddonBuilder.exe"
set CFGCONVERT="%TOOLSDIR%\CfgConvert\CfgConvert.exe"