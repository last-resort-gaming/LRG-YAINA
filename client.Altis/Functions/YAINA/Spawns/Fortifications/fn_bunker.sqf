/*
Function: YAINA_SPAWNS_fnc_Bunker

Description:
	Spawns a bunker position.

Parameters:
	_AOPos
	_AOSize
	_army
	_parentMissionID
	
Return Values:
	_bunits
	_bvehicles
	_bobjects

Examples:
    [[0,0,0], 400, "AAF", 6] call SFNC(Bunker);

Author:
	Matth
	Mokka
	Mitch
*/
#include "..\defines.h"

params ["_AOPos", "_AOSize", "_army", "_parentMissionID", "_BunkerElements"];

private ["_spawnPos", "_hiddenTerrainKey", "_bunkerFunc", "_bunits", "_bobjects", "_bvehicles", "_garrison"];

_bunits = [];
_bobjects = [];
_bvehicles = [];

_spawnPos = [_AOPos, 10, _AOSize, { !(_this isFlatEmpty [4, -1, 0.4, 10, 0, false, objNull] isEqualTo []) }] call YFNC(getPosAround);


_hiddenTerrainKey = format["HT_%1", _parentMissionID];
[clientOwner, _hiddenTerrainKey, _spawnPos, 20] remoteExec [QYFNC(hideTerrainObjects), 2];
waitUntil { !isNil {  missionNamespace getVariable _hiddenTerrainKey } };

_bunkerFunc = missionNamespace getVariable (selectRandom ( ["YAINA_SPAWNS_fnc", ["YAINA_SPAWNS", "Bunkers"]] call YFNC(getFunctions) ));

_BunkerElements = [_spawnPos, random 360, call _bunkerFunc] call BIS_fnc_ObjectsMapper;

_bobjects = _BunkerElements;

_garrison = [_spawnPos, [0,30], _army] call SFNC(infantryGarrison);

_bunits = _garrison;

[_bunits, _bvehicles, _bobjects]
