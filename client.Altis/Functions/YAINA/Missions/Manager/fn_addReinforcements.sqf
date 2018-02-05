/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_missionID", "_groups", "_vehs"];

// Send to Server in case of HCDCH, we can reuse this function
// as it's not got PFHs etc. that need starting and we already
// need to cleanup, so lets KISS
if (!isServer) then {
    _this remoteExecCall [QFNC(addReinforcements), 2];
};

private _idx = (GVAR(reinforcements) select 0) find _missionID;
if (_idx isEqualTo -1) then {
    (GVAR(reinforcements) select 0) pushBack _missionID;
    (GVAR(reinforcements) select 1) pushBack [[_groups, _vehs]];
} else {
    ((GVAR(reinforcements) select 1) select _idx) pushBack [_groups, _vehs];
};