/*
Function: YAINA_MM_fnc_startMissionPFH

Description:
	Handles starting the mission per-frame event handler, storing the
	relevant information on the server, but processing the event
	handler locally on the HC.

Parameters:
	_missionID - The ID of the newly created mission
	_missionType - The type of mission that has been created
	_stage - In what stage is the mission currently?
	_missionName - The name of the mission
	_parentMissionID - If applicable, the ID of the mission's parent (i.e. in Main AOs for Sub-Objectives)
	_markers - The markers associated with the mission
	_units - The units spawned for the mission
	_vehicles - The vehicles spawned for the mission
	_buildings - The building spawned for the mission
	_pfh - The newly created PFH for this mission
	_pfhDelay - PFH-relevant delay argument
	_pfhArgs - Arguments for the PFH

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_missionID", "_missionType", "_stage", "_missionName", "_parentMissionID", "_markers", "_units", "_vehicles", "_buildings", "_pfh", "_pfhDelay", "_pfhArgs"];

// Send it all to the server...along with our profileName
[
    profileName,
    _missionID, _missionType, _stage, _missionName, _parentMissionID, _markers, _units, _vehicles, _buildings, _pfh, _pfhDelay, _pfhArgs
] remoteExecCall [QFNC(addHCDCH), 2];

// Store local args for cleanup phase
(GVAR(localRunningMissions) select 0) pushBack _missionID;
(GVAR(localRunningMissions) select 1) pushBack [_markers, _units, _vehicles, _buildings];

// Start processing the PFH locally
[_pfh, _pfhDelay, _pfhArgs] call CBA_fnc_addPerFrameHandler;
