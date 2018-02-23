/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_veh", "_duration"];

YVAR(deleteVehiclesIn) pushBack [_veh, diag_tickTime + _duration];