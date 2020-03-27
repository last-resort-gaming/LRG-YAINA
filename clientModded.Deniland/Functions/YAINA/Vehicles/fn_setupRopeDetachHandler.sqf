/*
Function: YAINA_VEH_fnc_setupRopeDetachHandler

Description:
	This initializes the rope detach event handler for given vehicle.
    Functions pushed to the rddh array of such a vehicle will be
    executed whenever all ropes are detached.

Parameters:
	_veh - The vehicle for which we want to set up the RDEH

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_veh"];

_veh addEventHandler ["RopeBreak", {
    params ["_veh", "_rope", "_item"];

    // If it's the last rope, trigger the rddhs
    _rddh = _item getVariable QVAR(rddh);

    if (isNil "_rddh") exitWith {};

    // this can fire duplicates quickly due to the nature of
    // four ropes detaching quickly so, we just limit the
    // rate of firing per-item to 5 seconds

    if (isNull (ropeAttachedTo _item)) then {
        _last = _item getVariable [QVAR(rddh_fired), 0];
        if (diag_tickTime > (_last + 5)) then {
            _item setVariable [QVAR(rddh_fired), diag_tickTime, true];
            {
                [_item, _veh] call _x;
            } forEach _rddh;
        };
    };
}];

