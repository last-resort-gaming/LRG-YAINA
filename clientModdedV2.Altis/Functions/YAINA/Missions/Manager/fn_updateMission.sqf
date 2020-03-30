/*
Function: YAINA_MM_fnc_updateMission

Description:
	Update the given mission's stage and state.

Parameters:
	_missionID - The ID of the mission we want to update
    _stage - The mission's new stage
    _state - The mission's new state

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_missionID", "_stage", "_state"];
private ["_idx"];

// Find our mission and update the state accordingly
if (!isServer) exitWith {
    [_missionID, _stage, _state] remoteExecCall [QFNC(updateMission), 2];
};

{
    if (_x select 1 isEqualTo _missionID) exitWith {
        if (!isNil "_stage") then { GVAR(hcDCH) select _forEachIndex set [3, _stage] };
        if (!isNIl "_state") then { GVAR(hcDCH) select _forEachIndex set [2, _state] };
    };
} forEach GVAR(hcDCH);
