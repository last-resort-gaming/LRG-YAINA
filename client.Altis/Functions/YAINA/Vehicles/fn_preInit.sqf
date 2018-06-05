/*
Function: YAINA_VEH_fnc_preInit

Description:
	Handles initialization of required variables during preInit phase.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

if(isServer) then {

    // List of vehicles and their owners
    GVAR(owners) = [[],[]];

    // Managed Respawn List/PFH start
    GVAR(respawnList) = [];

};

if(hasInterface) then {
    GVAR(myVehicles) = [];
};