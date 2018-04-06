/*
	author: Martin
	description: none
	returns: nothing
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