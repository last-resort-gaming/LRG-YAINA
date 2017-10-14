/*
	author: MartinCo
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_target", "_caller", "_id", "_arguments"];

// if _target == _caller, then we are dropping all keys as it's a player action
if (_target isEqualTo _caller) then {
    [_target, nil, "remove"] remoteExecCall [QFNC(updateOwnership), 2];
    GVAR(myVehicles) = [];
} else {
    [_caller, _target, "remove"] remoteExecCall [QFNC(updateOwnership), 2];

    _idx = GVAR(myVehicles) find _target;
    if !(_idx isEqualTo -1) then {
        GVAR(myVehicles) deleteAt _idx;
    };
};

call FNC(updatePlayerActions);