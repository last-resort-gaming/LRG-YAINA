/*
Function: YAINA_VEH_fnc_dropKey

Description:
	Drops the keys to a vehicle (or all) and reset the ownership 
    status of the vehicles.

Parameters:
	_target - The player having their keys dropped
    _caller - The player that executed this function
    _id - The key ID for identification, unused
    _arguments - The arguments passed, unused

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
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