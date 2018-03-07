/*
	author: Martin
	description:
	    Gets all the units of units + reinforcements for
	    a given (local) mission ID
	returns: array of units
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