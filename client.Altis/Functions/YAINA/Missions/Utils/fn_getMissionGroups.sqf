/*
	author: Martin
	description:
	    Gets all the groups of units + reinforcements for
	    a given (local) mission ID
	returns: array of groups
*/

#include "..\defines.h"

params ["_missionID"];

private _idx = (GVAR(localRunningMissions) select 0) find _missionID;
if (_idx isEqualTo -1) exitWith {[]};

_groups = ((GVAR(localRunningMissions) select 1) select _idx) select 1;

// Have we any reinforcements?
private _idx = (GVAR(reinforcements) select 0) find _missionID;
if !(_idx isEqualTo -1) then {
    {
        _groups append (_x select 0);
    } count ((GVAR(reinforcements) select 1) select _idx);
};

_groups;
