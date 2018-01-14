/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_player"];

private _owner = owner _player;

private _lvl = 0;

private _idx = (GVAR(ownerIDs) select 0) find _owner;
if !(_idx isEqualTo -1) then {
    _lvl = ((GVAR(ownerIDs) select 1) select _idx) select 3;
};

// Also if they're HQ, they have an admin level of 1
if ([["HQ"], _player] call YFNC(testTraits)) then {
    _lvl = _lvl max 1;
};

_lvl