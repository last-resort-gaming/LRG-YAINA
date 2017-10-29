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

((GVAR(localRunningMissions) select 1) select _idx) select 1;

