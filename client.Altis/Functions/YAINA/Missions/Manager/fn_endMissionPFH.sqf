/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_missionID", "_pfhID"];

// remove PFH locally
[_pfhID] call CBAP_fnc_removePerFrameHandler;

// Delete Task
[_missionID] call BIS_fnc_deleteTask;

// Remove from localRunningMissions
_idx = (GVAR(localRunningMissions) select 0) find _missionID;
if !(_idx isEqualTo -1) then {
    (GVAR(localRunningMissions) select 0) deleteAt _idx;
    (GVAR(localRunningMissions) select 1) deleteAt _idx;
};

// Remove localBuildingRestores
_idx = (GVAR(localBuildingRestores) select 0) find _missionID;
if !(_idx isEqualTo -1) then {
    (GVAR(localBuildingRestores) select 0) deleteAt _idx;
    (GVAR(localBuildingRestores) select 1) deleteAt _idx;
};

// Remove reinforcements
_idx = (GVAR(reinforcements) select 0) find _missionID;
if !(_idx isEqualTo -1) then {
    (GVAR(reinforcements) select 0) deleteAt _idx;
    (GVAR(reinforcements) select 1) deleteAt _idx;
};

// Reqest server to stop monitoring
[profileName, _missionID] remoteExecCall [QFNC(delHCDCH), 2];