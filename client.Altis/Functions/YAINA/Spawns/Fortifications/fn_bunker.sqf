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
*/

systemchat "start";

#include "..\defines.h"

params ["_AOPos", "_AOSize", "_army", "_parentMissionID", "_BunkerElements"];

private ["_spawnPos", "_hiddenTerrainKey", "_bunkerFunc", "_bunits", "_bobjects", "_bvehicles"];

_bunits = [];
_bobjects = [];
_bvehicles = [];

_spawnPos = [_AOPos, 10, _AOSize, { !(_this isFlatEmpty [8, -1, 0.4, 10, 0, false, objNull] isEqualTo []) }] call YFNC(getPosAround);

// Testing Marker
createMarker ["MRK", _spawnPos];
"MRK" setMarkerType "hd_warning";

// Testing purposes
systemchat "Pos marked";
sleep 5;

_hiddenTerrainKey = format["HT_%1", _parentMissionID];
[clientOwner, _hiddenTerrainKey, _spawnPos, 50] remoteExec [QYFNC(hideTerrainObjects), 2];
waitUntil { !isNil {  missionNamespace getVariable _hiddenTerrainKey } };

// Testing purposes
systemChat "terrain hidden";
sleep 5;

//_bunkerFunc = missionNamespace getVariable (selectRandom ( ["YAINA_SPAWNS_fnc", ["YAINA_SPAWNS", "HQ"]] call FNC(getFunctions) ));

// _BunkerElements = [_spawnPos, random 360, call YAINA_SPAWNS_HQ_Courage;] call BIS_fnc_ObjectsMapper;

//Alternate
_bunkerFunc = missionNamespace getVariable (selectRandom ( ["YAINA_SPAWNS_fnc", ["YAINA_SPAWNS", "HQ"]] call FNC(getFunctions) ));

_BunkerElements = [_spawnPos, random 360, call _bunkerFunc] call BIS_fnc_ObjectsMapper;


// _BunkerElements = _bobjects;

// _garrison = [_spawnPos, [0,50], _army, 1] call SFNC(infantryGarrison);

_garrison = _bunits;

[_bunits, _bvehicles, _bobjects]
