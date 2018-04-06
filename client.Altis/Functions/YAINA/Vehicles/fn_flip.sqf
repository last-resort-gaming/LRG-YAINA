/*
	author: MartinCo
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_veh"];

if !(local _veh) exitWith {
    if (isServer) then {
        [_veh] remoteExecCall [QFNC(flip)];
    };
};

// To avoid blowing up, we move it up in the air, flip it vertical, and place it back down
_pos = getPosATL _veh;

_pos set [2, 2];
_veh setPosATL _pos;

_veh setVectorUp surfaceNormal position _veh;

_pos set [2, 0];
_veh setPosATL _pos;