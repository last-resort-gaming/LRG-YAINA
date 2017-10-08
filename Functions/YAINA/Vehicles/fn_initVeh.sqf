/*
	author: MartinCo
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_veh"];

_veh addAction ["Take Keys",  FNC(takeKey), "", -98, false, true, "", format['driver _target isEqualTo _this && isNil { _target getVariable "%1"; }', QVAR(owner)]];
_veh addAction ["Leave Keys", FNC(dropKey), "", -98, false, true, "", format['vehicle _this isEqualTo _target && _target getVariable "%1" isEqualTo _this; }', QVAR(owner)]];

// And relinquish ownershop of this vehicle if it gets killed
_veh addEventHandler ["killed", {
    params ["_veh", "_killer"];
    _owner = _veh getVariable QVAR(owner);
    if !(isNil "_owner") then {
        // just run drop key on the owner's machine to clean up their own map markers
        // and local vehicle list - this'll update the server too, so should be all
        // consistant.
        [_veh, _owner] remoteExec [QFNC(dropKey), _owner];
    };
}];

// Whilst adding it to Engine is nicer, you could get greifing with players refusing to get out
// So lets just add it to getIn / seat changed and force eject them from the vehicle.

_veh addEventHandler ["SeatSwitched", {
    params ["_veh", "_unit1", "_unit2"];

    _owner = _veh getVariable QVAR(owner);
    if (!(isNil "_owner") && !(_owner isEqualTo (driver _veh))) then {
        ["You don't have the keys."] remoteExec [QFNC(hintC), driver _veh];
        moveOut driver _veh;
    };
}];

_veh addEventHandler ["GetIn", {
    params ["_veh", "_pos", "_unit", "_turret"];
    if (_pos isEqualTo "driver") then {
        _owner = _veh getVariable QVAR(owner);
        if (!(isNil "_owner") && !(_owner isEqualTo (driver _veh))) then {
            ["You don't have the keys."] remoteExec [QFNC(hintC), _unit];
            moveOut _unit;
        };
    };
}];

true;