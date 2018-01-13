/*
	author: Martin
	description: none
	returns: nothing
*/


#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

YAINA_MM_paused = !YAINA_MM_paused;

private _msg = format ["%1 the mission manager", ["resumed", "paused"] select YAINA_MM_paused];

// Let everyone on side know they've done it
[_caller, format ["I have %1", _msg]] remoteExecCall ["sideChat"];

_msg;