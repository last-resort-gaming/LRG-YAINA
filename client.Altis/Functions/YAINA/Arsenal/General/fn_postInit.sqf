/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

private _arsenals = [];

[ARSENALS] call FNC(initArsenal);

// Player take handler, if the weapon hold is BLUFOR then we enforce weapon restrictions

player addEventHandler ["Take", {
    params ["_unit", "_container", "_item"];
    [_unit, _item, _container] call FNC(enforceGear);
}];

