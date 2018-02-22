/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_player"];

if (isNil QYVAR(ownerIDs)) exitWith { 5 };

private _owner = owner _player;

private _lvl = 5;

private _idx = (YVAR(ownerIDs) select 0) find _owner;
if !(_idx isEqualTo -1) then {
    _lvl = ((YVAR(ownerIDs) select 1) select _idx) select 3;
};

_lvl