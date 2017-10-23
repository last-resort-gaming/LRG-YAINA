/*
	author: Martin
	description: none
	returns: nothing
*/


#include "defines.h"
player addEventHandler["FiredMan", {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_mag", "_projectile", "_veh"];

    // Permit Flares
    if (_weapon isEqualTo "CMFlareLauncher")  exitWith {true};

    _checkObject = [_veh, _unit] select isNull _veh;
    {
        if (_checkObject inArea _x) exitWith {
            deleteVehicle _projectile;
            "Do not fire in base" remoteExecCall [Q(YFNC(hintC)), _unit];
            true;
        };
        false;
    } count BASE_PROTECTION_AREAS;
}];