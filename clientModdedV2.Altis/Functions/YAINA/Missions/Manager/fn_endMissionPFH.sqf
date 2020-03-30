/*
Function: YAINA_MM_fnc_endMissionPFH

Description:
	Handles removal of the mission-specific per-frame handler after
    mission completion.
    Removes the task, associated modules such as running missions,
    building restores, reinforcements and mission monitoring by the server.

Parameters:
	_missionID - The ID of the mission that we want to end
    _pfhID - The ID of the associated PFH

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_missionID", "_pfhID"];

// remove PFH locally
[_pfhID] call CBA_fnc_removePerFrameHandler;

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