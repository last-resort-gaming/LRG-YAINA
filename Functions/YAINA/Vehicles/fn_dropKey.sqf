/*
	author: MartinCo
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_target", "_caller", "_id", "_arguments"];

// if _target == _caller, then we are dropping all keys as it's a player action
if (_target isEqualTo _caller) then {
    [_target, nil, "remove"] remoteExec [QFNC(updateOwnership), 2];

    {
        _mm = _x getVariable QVAR(mm);
        if !(isNil "_mm") then {  deleteMarkerLocal _mm; };
    } count GVAR(myVehicles);
    GVAR(myVehicles) = [];

} else {
    [_caller, _target, "remove"] remoteExec [QFNC(updateOwnership), 2];

    _idx = GVAR(myVehicles) find _target;
    if !(_idx isEqualTo -1) then {

        _mm = (GVAR(myVehicles) select _idx) getVariable QVAR(mm);
        if !(isNil "_mm") then {  deleteMarkerLocal _mm; };

        GVAR(myVehicles) deleteAt _idx;
    };
};

call FNC(updatePlayerActions);