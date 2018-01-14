/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_caller", "_msg", "_level"];

_msg = format ["%1: %2", name _caller, _msg];

{
    if (_x select 3 >= _level) then {
        [_msg] remoteExec ["systemChat", (YVAR(ownerIDs) select 0) select _forEachIndex];
    };
} forEach (YVAR(ownerIDs) select 1);