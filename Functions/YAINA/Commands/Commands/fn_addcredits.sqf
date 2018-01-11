/*
	author: Martin
	description: none
	returns: nothing
*/


#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _add = floor (parseNumber _argStr);

// Bail if not an integer
if !((str _add) isEqualTo _argStr) exitWith { format ["Invalid Amount: %1", _argStr]; };

// Bail if 0
if (_add isEqualTo 0) exitWith { "Requested 0"; };

[_add] call YFNC(addRewardPoints);

// Format string
_msg = format ["%1 %2 credits for a total of %3", ["added", "removed"] select (_add < 0), abs _add, YVAR(rewardPoints)];

// Let everyone on side know they've done it
[_caller, format ["I have %1", _msg]] remoteExecCall ["sideChat"];

_msg;