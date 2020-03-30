/*
Function: YAINA_MM_fnc_stopMission

Description:
	Requests the given mission's termination.

Parameters:
	_missionID - ID of the mission we want to stop

Return Values:
	The index of the pushed back stop request, or -1 if pushing back failed

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_missionID"];

GVAR(stopRequests) pushBackUnique _missionID;