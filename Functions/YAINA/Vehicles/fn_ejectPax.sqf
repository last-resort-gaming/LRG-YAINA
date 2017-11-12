/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_pilotName"];

if ((vehicle player) isKindOf "Air") then {

    player setVariable [QYVAR(noPara), format["You were ejected by %1", _pilotName]];
    moveOut player;

    // Then set noPara back once we're on ground
    [
        {isTouchingGround (vehicle player)},
        {
            player setVariable [QYVAR(noPara), nil];
        }
    ] call CBA_fnc_waitUntilAndExecute;
};


