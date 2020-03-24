/*
Function: YAINA_MM_fnc_setMissionID

Description:
	Keeps track of the mission IDs for each profile, this is
	used for when an HC disconnects / reconnects, it doesn't
	start using a potentially conflicting mission ID.
	
Parameters:
	_profileName - Profile name of the HC, used for identification
	_missionID - ID of the mission which we want to set on the HC

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
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