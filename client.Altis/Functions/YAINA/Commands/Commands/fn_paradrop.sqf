/*
Function: YAINA_CMD_fnc_paradrop

Description:
	Override the current paradrop status (optionally for a limited time)
    and allow players to use the feature even when pilots are online.

Parameters:
	_owner - Not used
    _caller - The player that called this command
    _argStr - Override for given amount of time (minutes)

Return Values:
	Compiled message for internal handling

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

// This returns 0 for non-numeric, so that fits our needs
private _duration = (parseNumber _argStr) * 60;

// Set the drop time for n minutes
YAINA_MM_paradropOverride = LTIME + _duration;

// If time is 0, we've disabled the paradrop override
private _msg = call {
    if (_duration isEqualTo 0) exitWith { "Admin paradrop override disabled"; };
    format ["Admin paradrop enabled for %1", [_duration] call YFNC(formatDuration)];
};

private _gmsg = call {
    if (_duration isEqualTo 0) exitWith { "Paradrop override has been suspended"; };
    format ["I have enabled paradrop for %1", [_duration] call YFNC(formatDuration)];
};

// In this case, we let players know it's happend
[_caller, _gmsg] remoteExecCall ["sideChat"];

_msg;