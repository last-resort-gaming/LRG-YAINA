/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

[[
    arsenal_1,
    arsenal_2,
    arsenal_3,
    arsenal_4,
    arsenal_5,
    arsenal_6,
    arsenal_7,
    arsenal_9
]] call FNC(initArsenal);

// Player take handler, if the weapon hold is BLUFOR then we enforce weapon restrictions

private _takeHandler = {
    player addEventHandler ["Take", {
        params ["_unit", "_container", "_item"];

        if (_container getVariable [QVAR(filtered), false]) then {
            [_unit, _item, _container] call FNC(enforceGear);
        };
    }];
};

call _takeHandler;
//player addEventHandler ["Respawn", _takeHandler];


