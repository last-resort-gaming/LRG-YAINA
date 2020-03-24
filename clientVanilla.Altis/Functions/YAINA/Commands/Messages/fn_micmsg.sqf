/*
Function: YAINA_CMD_fnc_micmsg

Description:
	Prints out a message informing about TS requirements for 
    specific roles.

Parameters:
	_owner - The owner of the player object that called this command
    _caller - Not used
    _argStr - The player we want to target (if any)

Return Values:
	Compiled message for internal handling

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _ret = nil;
private _log = nil;
private _msg = "%1, welcome to the Last Resort Gaming public server. You are now required to be on our Discord server and have a microphone to play in your role. Please do so immediately or you will be removed from your slot.";

if (_argStr isEqualTo "") then {
    // General message, we let everyone know who is in a mic required slot
    _pl = [];
    _c = {
        if ([["MERT", "PILOT", "UAV", "HQ"], _x] call YFNC(testTraits)) then {
            _pl pushBack (name _x);
            [[west, "HQ"], format[_msg, name _x]] remoteExec ["sideChat", _x];
            true
        } else {
            false;
        }
    } count allPlayers;

    _ret = format ["micmsg sent to %1 players", _c];
    _log = format ["micmsg sent to %1", _pl joinString ", "];
} else {

    private _p = [_argStr] call FNC(findPlayer);

    if (_p isEqualTo []) then {
        _ret = format["no player matching %1", _pn];
    } else {
        if !(count _p isEqualTo 1) then {
            _ret = format ["too many matches for prefix %1", _pn];
        } else {

            _player = _p select 0;

            _ret = format["micmsg sent to %1", name _player];

            _msg = format[_msg, name _player];
            _msg remoteExec [QYFNC(hintC), _player];
            [[west, "HQ"], _msg] remoteExec ["sideChat", _player];
        };
    };
};

if !(isNil "_ret") then {
    _ret remoteExecCall ["systemChat", _owner];
};

if (isNil "_log" && { not isNil "_ret" }) then {
    _log = _ret;
};

_log;