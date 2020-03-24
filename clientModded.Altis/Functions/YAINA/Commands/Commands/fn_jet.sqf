/*
Function: YAINA_CMD_fnc_jet

Description:
	Spawn in CAS on one of the Main AOs. Spawning can be
    enforced.

Parameters:
	_owner - The owner of the player that called the command
    _caller - Not used
    _argStr - true to force spawning, defaults to false

Return Values:
	Compiled message for internal handling

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

// Pick a random main AO, and call CAS in
private _AOs = [];
private _msg = "";


// Force if argument is true
private _force = (toLower _argStr) isEqualTo "true";

{
    if ((_x select 2) isEqualTo "AO") then { _AOs pushBack (_x select 1) };
    nil
} count YAINA_MM_hcDCH;

if (_AOs isEqualTo []) then {
    _msg = "Couldn't find an AO to call CAS in on";
} else {
    _AO = selectRandom _AOs;
    [getMarkerPos format ["%1_mrk1", _AO], 1000, _force] call YAINA_SPAWNS_fnc_CAS;
    _msg = format["Called in CAS on %1",  _AO];
};

_msg remoteExecCall ["systemChat", _owner];
_msg