/*
Function: YAINA_fnc_deleteVehicleIn

Description:
	Primes a vehicle for deletion after the given amount of time.

Parameters:
	_veh - The vehicle that shall be deleted after given amount of time
	_duration - Time until deletion in ms

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_veh", "_duration"];

YVAR(deleteVehiclesIn) pushBack [_veh, diag_tickTime + _duration];