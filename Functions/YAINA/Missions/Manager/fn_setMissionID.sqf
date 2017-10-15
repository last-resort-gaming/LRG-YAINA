/*
	author: Martin
	description:
	    Keeps track of the mission IDs for each profile, this is
	    used for when an HC disconnects / reconnects, it doesn't
	    start using a potentially conflicting mission ID.
	returns: nothing
*/

#include "..\defines.h"
if(!isServer) exitWith {};

params ["_profileName", "_missionID"];

TRACE_2("setMissionID", _profileName, _missionID);

// Add / Update the missionID accordingly
private _idx = (GVAR(hcMissionID) select 0) find _profileName;
if (_idx isEqualTo -1) then {
    (GVAR(hcMissionID) select 0) pushBack _profileName;
    (GVAR(hcMissionID) select 1) pushBack _missionID;
} else {
    (GVAR(hcMissionID) select 1) set [_idx, _missionID];
};

publicVariable QVAR(hcMissionID);