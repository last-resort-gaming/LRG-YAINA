/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

// Simply just lists available commands on their system
private _avail = [];

// Grab list of their commands
_idx = (GVAR(commands) select 0) find _owner;
if (_idx isEqualTo -1) exitWith {
    diag_log format['FAILED TO FIND COMMANDS FOR %1', name _caller];
};

_avail = ((GVAR(commands) select 1) select _idx) + [];

// Some of the commands, aren't really real (such as admin-nofifications and ALL)
// so we remove those from the list
private _n = (count _avail) - 1;
for "_i" from _n to 0 step -1 do {
    private _tst = _avail select _i;
    private _cmd = missionNamespace getVariable format["YAINA_CMD_fnc_%1", _tst];
    if (isNil "_cmd" && { !(_tst in GVAR(becCommands)) } ) then {
        _avail deleteAt _i;
    };
};

// Sort the list and output it
_avail sort true;

_msg = format["Available Commands: %1", _avail joinString ", "];

_msg remoteExec ["systemChat", _caller];

_msg