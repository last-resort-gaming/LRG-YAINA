/*
Function: YAINA_CMD_fnc_mmstart

Description:
	Start a new instance of the selected type of mission.

Parameters:
	_owner - Not used
	_caller - Not used
	_argStr - The type (or name of the) mission to be started

Return Values:
	Compiled message for internal handling

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

_argStr = toLower _argStr;

if (YAINA_MM_paused) then {
	YAINA_MM_paused = false;
	[_caller, "Mission Cycle unpaused."] remoteExecCall ["sideChat"];
};

if (_argStr isEqualTo "side") then {
    _argStr = selectRandom ([nil, ["YAINA_MM_OBJ", "SideMissions"]] call YAINA_MM_fnc_getFunctions);
};

if (_argStr isEqualTo "priority") then {
    _argStr = selectRandom ([nil, ["YAINA_MM_OBJ", "Priority"]] call YAINA_MM_fnc_getFunctions);
};

private _mission = format["YAINA_MM_OBJ_fnc_%1", _argStr];

if (isNil { missionNamespace getVariable _mission } ) exitWith {
    _msg = format ["Invalid Mission Name: %1", _argStr];
	_msg remoteExecCall ["systemChat", _owner];
	_msg;
};

[_mission] call YAINA_MM_fnc_startMission;

_msg = format ["Started Mission: %1", _argStr];
_msg remoteExecCall ["systemChat", _owner];
_msg;