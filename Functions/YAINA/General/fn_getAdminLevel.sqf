/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_player"];

private _uid = getPlayerUID _player;
private _idx = (GVAR(admins) select 0) find _uid;
private _lvl = 0;

if !(_idx isEqualTo -1) then {
    _lvl = (GVAR(admins) select 1) select _idx;
};

if ([["HQ"], _player] call YFNC(testTraits)) then {
    _lvl = _lvl max 1;
};

_lvl