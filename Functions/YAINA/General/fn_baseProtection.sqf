/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

player addEventHandler["Fired", {
    params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_mag", "_projectile", "_gunner"];
    {
        if (_unit inArea _x) exitWith {
            deleteVehicle _projectile;
            "Do not fire in base" remoteExecCall [Q(YFNC(hintC)), _unit];
            true;
        };
        false;
    } count BASE_PROTECTION_AREAS;
}];