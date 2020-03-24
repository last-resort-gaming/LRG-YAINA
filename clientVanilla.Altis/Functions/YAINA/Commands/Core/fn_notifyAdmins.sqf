/*
Function: YAINA_CMD_fnc_notifyAdmins

Description:
	Notify active server admins of impeeding doom (or 
	something along those lines).

Parameters:
	_caller - The player that wants to notify the admin(s)
	_msg - The notification to be sent to the admin(s)
	_level - Not used, possibly intended for the priority of the notification

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_caller", "_msg", "_level"];

_msg = format ["%1: %2", name _caller, _msg];

{
    if ('notify-admins' in _x || { 'ALL' in _x } ) then {
        [_msg] remoteExec ["systemChat", (GVAR(commands) select 0) select _forEachIndex];
    };
} forEach (GVAR(commands) select 1);