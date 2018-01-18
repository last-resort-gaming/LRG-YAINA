/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_missionID", "_stage"];
private ["_idx"];

// Find our mission and update the state accordingly
if (!isServer) exitWith {
    [_missionID, _stage] remoteExecCall [QFNC(updateMissionStage), 2];
};

{
    if (_x select 1 isEqualTo _missionID) exitWith {
        GVAR(hcDCH) select _forEachIndex set [3, _stage];
    };
} forEach GVAR(hcDCH);
