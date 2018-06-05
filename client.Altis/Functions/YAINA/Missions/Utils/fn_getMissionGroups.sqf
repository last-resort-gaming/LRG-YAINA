/*
Function: YAINA_MM_fnc_getMissionGroups

Description:
	Gets all the groups of units + reinforcements for
	a given (local) mission ID

Parameters:
	_missionID - ID of the mission we want to get the groups from

Return Values:
	Array of group of the mission

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_missionID"];

private _units = [_missionID] call FNC(getMissionUnits);
private _grps  = [];

{
    if (alive _x) then { _grps pushBackUnique (group _x) };
    nil;
} count _units;

_grps;