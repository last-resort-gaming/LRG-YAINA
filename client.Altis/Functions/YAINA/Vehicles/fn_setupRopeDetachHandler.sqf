/*
	author: Martin
	description: none
	returns: nothing
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

