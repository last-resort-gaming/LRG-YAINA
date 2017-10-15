/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

INCR(GVAR(localMissionID));

// Send to server to in case of rejoin
[profileName, GVAR(localMissionID)] remoteExecCall [QFNC(setMissionID), 2];

// Return Mission ID
format ["yaina_m_%1_%2", profileName, GVAR(localMissionID)];