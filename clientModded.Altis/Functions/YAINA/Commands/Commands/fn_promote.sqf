/*
Function: YAINA_CMD_fnc_promote

Description:
	Promote the given player the the leader of their group.

Parameters:
	_owner - The owner of the player object that called this command
    _caller - Not used
    _argStr - The player which we want to promote

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
        _p = _p select 0;
        _g = group _p;
        [_g, _p] remoteExec ["selectLeader", groupOwner _g];
        _ret = format ["%1 has been promoted to group lead", name _p];
    };
};

_ret remoteExecCall ["systemChat", _owner];
_ret