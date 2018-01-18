/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_missionID"];

GVAR(stopRequests) pushBackUnique _missionID;