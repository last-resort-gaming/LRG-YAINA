/*
Function: YAINA_CMD_fnc_settrait

Description:
	Set the targeted player's traits or remove them from him.

Parameters:
	_owner - The owner of the player object that called this command
    _caller - The player that called this command
    _argStr - The player we want to target and the traits we want to add or remove

Return Values:
	Compiled message for internal handling

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _argSplit = _argStr splitString " ";
private _trait = toLower (_argSplit deleteAt 0);
private _playerName = _argStr select [count _trait + 1];

private _p = [_playerName] call FNC(findPlayer);
private _ret = "";

if (isNil "_trait" || { _trait isEqualTo "" })  exitWith {
    _ret = '!settrait <TRAIT> <Player>, use -TRAIT to remove a trait';
    _ret remoteExecCall ["systemChat", _owner];
    _ret
};

if (_p isEqualTo []) then {
    _ret = format["no player matching %1", _playerName];
} else {
    if !(count _p isEqualTo 1) then {
        _ret = format ["too many matches for prefix %1", _playerName];
    } else {

        _p = _p select 0;
        _add = true;
        if (_trait select [0,1] isEqualTo "-") then {
            _trait = _trait select [1, (count _trait) - 1];
            _add  = false;
        };

        _traits = _p getVariable ["YAINA_TRAITS", []];
        _idx = _traits find _trait;
        if !(_idx isEqualTo -1) then {
            if (_add) then {
                _ret = format ["%1 already has trait: %2", name _p, _trait];
            } else {
                _traits deleteAt _idx;
                _p setVariable ['YAINA_TRAITS', _traits, true];
                _ret = format ["%1 has had the following trait removed: %2", name _p, _trait];
                format ["You no longer have trait: %1", _trait] remoteExec ["systemChat", _p];
            };
        } else {
            if (_add) then {
                _traits pushBack _trait;
                _p setVariable ['YAINA_TRAITS', _traits, true];
                _ret = format ["%1 now has trait: %2", name _p, _trait];
                format ["You have been given the following trait: %1", _trait] remoteExec ["systemChat", _p];
            } else {
                _ret = format ["%1 doesn't have trait: %2", name _p, _trait];
            };
        };

        [_caller, _ret, 2] call FNC(notifyAdmins);
    };
};

_ret remoteExecCall ["systemChat", _owner];
_ret