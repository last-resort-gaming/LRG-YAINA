
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