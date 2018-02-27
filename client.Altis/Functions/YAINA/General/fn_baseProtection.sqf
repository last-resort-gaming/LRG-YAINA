/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

{

    _m = _x;
    _c = getMarkerPos _x;
    _s = getMarkerSize _x;
    _w = (_s select 0) max (_s select 1);

    { _x allowDamage false; nil } count (nearestTerrainObjects [_c, [], _w, false, true] select { _x inArea _m });

    nil;
} count BASE_PROTECTION_AREAS;

player addEventHandler["FiredMan", {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_mag", "_projectile", "_veh"];

    // Permit Flares / zeusing
    if (_weapon isEqualTo "CMFlareLauncher")  exitWith {true};
    if !(cameraOn isEqualTo (vehicle player)) exitWith {true};

    _checkObject = [_veh, _unit] select isNull _veh;
    {
        if (_checkObject inArea _x) exitWith {
            deleteVehicle _projectile;
            "Do not fire in base" remoteExecCall [QYFNC(hintC), _unit];
            true;
        };
        false;
    } count BASE_PROTECTION_AREAS;
}];
