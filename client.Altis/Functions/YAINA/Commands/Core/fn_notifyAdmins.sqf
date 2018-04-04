/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_caller", "_msg", "_level"];

_msg = format ["%1: %2", name _caller, _msg];

{
    if ('notify-admins' in _x || { 'ALL' in _x } ) then {
        [_msg] remoteExec ["systemChat", (GVAR(commands) select 0) select _forEachIndex];
    };
} forEach (GVAR(commands) select 1);