/*
Function: YAINA_MM_fnc_getMissionUnits

Description:
    Gets all the units of units + reinforcements for
    a given (local) mission ID

Parameters:
	_missionID - The ID of the mission which units we want

Return Values:
	Array of units

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_missionID"];

private _idx = (GVAR(localRunningMissions) select 0) find _missionID;
if (_idx isEqualTo -1) exitWith {[]};

// Duplicate the array
_units = (((GVAR(localRunningMissions) select 1) select _idx) select 1) + [];

// Have we any reinforcements?
private _idx = (GVAR(reinforcements) select 0) find _missionID;
if !(_idx isEqualTo -1) then {
    {
        _units append (_x select 0);
    } forEach ((GVAR(reinforcements) select 1) select _idx);
};

_units;
