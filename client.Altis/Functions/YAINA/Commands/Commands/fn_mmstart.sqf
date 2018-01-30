/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _mission = format["YAINA_MM_OBJ_fnc_%1", _argStr];

if (isNil { missionNamespace getVariable _mission } ) exitWith {
    format ["Invalid Mission Name: %1", _argStr];
};

[_mission] call YAINA_MM_fnc_startMission;

format ["Started Mission: %1", _argStr];