/*
Function: YAINA_MM_fnc_addReinforcements

Description:
	Register given units and vehicles as reinforcements for the given
    mission, referenced by missionID.

Parameters:
	_missionID - The ID of the mission for which we want to register the reinforcements
    _units - The units we want to register as reinforcements
    _vehs - The vehicles we want to register as reinforcements

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_missionID", "_units", "_vehs"];

// Send to Server in case of HCDCH, we can reuse this function
// as it's not got PFHs etc. that need starting and we already
// need to cleanup, so lets KISS
if (!isServer) then {
    _this remoteExecCall [QFNC(addReinforcements), 2];
};

private _idx = (GVAR(reinforcements) select 0) find _missionID;
if (_idx isEqualTo -1) then {
    (GVAR(reinforcements) select 0) pushBack _missionID;
    (GVAR(reinforcements) select 1) pushBack [[_units, _vehs]];
} else {
    ((GVAR(reinforcements) select 1) select _idx) pushBack [_units, _vehs];
};