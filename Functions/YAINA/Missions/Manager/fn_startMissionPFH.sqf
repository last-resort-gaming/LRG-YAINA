/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_missionID", "_missionType", "_stage", "_markers", "_groups", "_vehicles", "_buildings", "_pfh", "_pfhDelay", "_pfhArgs"];

// Send it all to the server...along with our profileName
[
    profileName,
    _missionID, _missionType, _stage, _markers, _groups, _vehicles, _buildings, _pfh, _pfhDelay, _pfhArgs
] remoteExecCall [QFNC(addHCDCH), 2];

// Store local args for cleanup phase
(GVAR(localRunningMissions) select 0) pushBack _missionID;
(GVAR(localRunningMissions) select 1) pushBack [_markers, _groups, _vehicles, _buildings];

// Start processing the PFH locally
[_pfh, _pfhDelay, _pfhArgs] call CBA_fnc_addPerFrameHandler;
