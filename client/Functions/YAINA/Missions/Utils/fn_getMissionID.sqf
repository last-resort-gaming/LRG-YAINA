/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

INCR(GVAR(localMissionID));

private _missionProfile = (profileName splitString "-,. ") joinString "";

// Send to server to in case of rejoin
[_missionProfile, GVAR(localMissionID)] remoteExecCall [QFNC(setMissionID), 2];

// Return Mission ID
format ["yaina_m_%1_%2", _missionProfile, GVAR(localMissionID)];