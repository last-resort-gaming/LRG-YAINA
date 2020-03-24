/*
Function: YAINA_CMD_fnc_repair

Description:
	Repair the vehicle in which the given player is sitting.

Parameters:
	_owner - The owner of the player object that called this command
    _caller - Not used
    _argStr - The player whose vehicle we wish to repair

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
        _v = vehicle _p;

        if !(_v isEqualTo _p) then {
            _v setDamage 0;
            _v setFuel 1;
            _ret = format ["%1's vehicle has been repaired", name _p];
        } else {
            _ret = format ["%1 doesn't appear to be in a vehicle", name _p];
        };
    };
};

_ret remoteExecCall ["systemChat", _owner];
_ret