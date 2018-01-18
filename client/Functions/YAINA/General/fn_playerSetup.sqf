/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if !(hasInterface) exitWith {};

player addEventHandler ["Respawn", {
    call YFNC(playerSetupRespawn);
}];

call YFNC(playerSetupRespawn);