/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_player", "_check"];

if !(isServer) exitWith {};


private _owner = owner _player;
private _idx   = (GVAR(commands) select 0) find _owner;

if (_idx isEqualTo -1) exitWith { false };

private _cmds = (GVAR(commands) select 1) select _idx;

_check pushBackUnique "ALL";

_found = {
    if (_x in _cmds) exitWith { true };
    false
} count _check;

_found isEqualTo true;
