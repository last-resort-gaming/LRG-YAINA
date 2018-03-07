/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

INCR(GVAR(localMissionID));

private _missionProfile = ((profileName splitString "-,. ") joinString "") select [0, 3];

// Send to server to in case of rejoin
[_missionProfile, GVAR(localMissionID)] remoteExecCall [QFNC(setMissionID), 2];

// Return Mission ID
format ["m_%1_%2", _missionProfile, GVAR(localMissionID)];