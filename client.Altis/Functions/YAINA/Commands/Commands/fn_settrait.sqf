/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _argSplit = _argStr splitString " ";
private _trait = toUpper (_argSplit deleteAt 0);
private _playerName = _argStr select [count _trait + 1];

private _p = [_playerName] call FNC(findPlayer);
private _ret = "";

if (_p isEqualTo []) then {
    _ret = format["no player matching %1", _pn];
} else {
    if !(count _p isEqualTo 1) then {
        _ret = format ["too many matches for prefix %1", _pn];
    } else {
        [[_trait], {
            _t = _this select 0;
            _t call YAINA_FNC_setUnitTrait;

            // Let player know
            systemChat format["You now have the %1 trait", _t];
        }] remoteExec ["call", _p select 0];

        // Let admins know
        _ret = format ["set unitTrait %1 on player: %2", _trait, name (_p select 0)];
        [_caller, _ret, 2] call FNC(notifyAdmins);
    };
};

_ret remoteExecCall ["systemChat", _owner];
_ret