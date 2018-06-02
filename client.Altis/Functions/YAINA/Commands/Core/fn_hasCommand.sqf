/*
Function: YAINA_CMD_fnc_hasCommand

Description:
	Checks, if given player has access to the given command(s).

Parameters:
	_player - The player which we want to check against
	_check - Array of commands which we want to check for

Return Values:
	true if commands are available to the players, false otherwise

Examples:
    Nothing to see here

Author:
	Martin
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
