/*
Function: YAINA_ZEUS_fnc_migrate

Description:
	Migrate a unit from the Zeus to a headless client.

Parameters:
	_target - The unit we want to migrate to a HC.

Return Values:
	true, if successfully migrated to a HC, false otherwise

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_target"];

if !(isServer) exitWith {};

// _target maybe a group, unit, or vehicle
// we just change the select a random HC
// TODO: hcList really be in general rather than MM specific

// By default, we move to the server
private _destination = 2;

// Get the owner
private _tmp = selectRandom (YAINA_MM_hcList apply { owner (missionNamespace getVariable _x) } select { !(isNil { _x } ) });

if !(isNil "_tmp") then {
    _destination = _tmp;
};

// If we are a group...
if ((typeName _target) isEqualTo "GROUP") exitWith {
    _target setGroupOwner _destination;
};

// Anything else...we just throw on its own
_target setOwner _destination;