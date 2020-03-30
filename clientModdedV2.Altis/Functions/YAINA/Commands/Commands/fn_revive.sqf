/*
Function: YAINA_CMD_fnc_revive

Description:
	Revives that targeted player.

Parameters:
	_owner - The owner of the player object that called this command
    _caller - Not used
    _argStr - The player who we want to revive

Return Values:
	Compiled message for internal handling

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _p = [_argStr] call FNC(findPlayer);
private _ret = "";

if (_p isEqualTo []) then {
    _ret = format["no player matching %1", _argStr];
} else {
    if !(count _p isEqualTo 1) then {
        _ret = format ["too many matches for prefix %1", _argStr];
    } else {
        [_p select 0] call AIS_System_fnc_forceRevivePlayer;
        _ret = format ["%1 has been revived", name (_p select 0)];
    };
};

_ret remoteExecCall ["systemChat", _owner];
_ret