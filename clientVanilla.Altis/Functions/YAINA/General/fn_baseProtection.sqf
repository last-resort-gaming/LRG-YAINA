/*
Function: YAINA_fnc_baseProtection

Description:
	Handles initialization of the base protection during the postInit
    phase. All terrain objects at base are made invincible, and the
    conditional projectile removal is added via event handler.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
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

    // If allowed to fire at base, just ignore this
    if (yaina_allow_firing_at_base) exitWith {true};

    // Permit Flares / zeusing
    if (_weapon in ["CMFlareLauncher", "CMFlareLauncher_Singles", "CMFlareLauncher_Triples"])  exitWith {true};
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
