/*
Function: YAINA_CMD_fnc_mmstop

Description:
	Stop all or a specific (type of) mission(s).

Parameters:
	_owner - The owner of the player object that called this command
    _caller - The player that called this command
    _argStr - The mission (type) to be stopped, empty or "all" to stop all

Return Values:
	Compiled message for internal handling

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _msg = "";
private _selector = {true};
private _missionDescription = "all";

if (_argStr isEqualTo "") then { _argStr = "all"; };
if (_argStr isEqualTo "all") then {
    YAINA_MM_paused = true;
} else {
    _selector = { (_x select 1) isEqualTo _argStr || { (_x select 5) isEqualTo _argStr } };
};

private _c = [];
private _n = {
    // Server always keeps it in case of HC DC race
    [_x select 1] call YAINA_MM_fnc_stopMission;

    // Update description
    if ((_x select 1) isEqualTo _argStr) then {
        _missionDescription = _x select 4;
    };

    // And additionally to HC if running on HC
    _hcID = YAINA_MM_hcList find (_x select 0);
    if !(_hcID isEqualTo -1) then {
        [(_x select 1)] remoteExec ["YAINA_MM_fnc_stopMission", (_x select 0)];
    };

    _c pushBack (_x select 1);
    true;
} count (YAINA_MM_hcDCH select _selector);

if (_n isEqualTo 0) then {
    _msg = format["invalid mission id: %1", _argStr];
    _msg remoteExec ["systemChat", _owner];
} else {
    if (_argStr isEqualTo "all") then {
        _msg = "all";
        [_caller, "I have stopped the mission manager, and cleared the objectives"] remoteExecCall ["sideChat"];
    } else {
        [_caller, format["Stopping mission: %1", _missionDescription]] remoteExecCall ["sideChat"];
        _msg = _c joinString ", ";
    };
};

"mission stop requested" remoteExec ["systemChat", _owner];

_msg
