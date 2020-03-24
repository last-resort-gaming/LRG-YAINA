/*
Function: YAINA_CMD_fnc_mmpause

Description:
	Pause or resume the mission manager, and thus the mission 
	life cycle.

Parameters:
	_owner - Not used
	_caller - The player that called this command
	_argStr - Not used

Return Values:
	Compiled message for internal handling

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

YAINA_MM_paused = !YAINA_MM_paused;

private _msg = format ["%1 the mission manager", ["resumed", "paused"] select YAINA_MM_paused];

// Let everyone on side know they've done it
[_caller, format ["I have %1", _msg]] remoteExecCall ["sideChat"];

_msg;