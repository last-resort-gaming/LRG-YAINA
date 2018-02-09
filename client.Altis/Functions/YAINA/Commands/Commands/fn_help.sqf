/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

// Simply just lists available commands on their system
private _avail = [];
private _lvl = [_caller] call YFNC(getAdminLevel);

{
    if (_x <= _lvl) then {
        _avail pushBack ((GVAR(commands) select 0) select _forEachIndex);
    };
} forEach (GVAR(commands) select 1);

// Sort the list and output it
_avail sort true;

_msg = format["Available Commands: %1", _avail joinString ", "];

_msg remoteExec ["systemChat", _caller];

_msg