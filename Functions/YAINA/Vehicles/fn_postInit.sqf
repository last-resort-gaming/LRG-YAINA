/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if(isServer) then {

    [] call FNC(respawnPFH);

    // And unlock all the players vehicles on DC
    addMissionEventHandler ["HandleDisconnect", { [_this select 0, nil, "remove"] call FNC(updateOwnership) } ];

};

if(hasInterface) then {

    // And we need a respawn handler to add back in the player actioon for unlcoking all vehicles
    player addEventHandler ["Respawn", {
        call FNC(updatePlayerActions);
    }];

};