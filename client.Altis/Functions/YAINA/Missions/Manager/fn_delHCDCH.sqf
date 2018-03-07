/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_profileName", "_missionID"];

// And remove the marker

private _hcDCH    = GVAR(hcDCH) select { _x select 0 isEqualTo _profileName && { _x select 1 isEqualTo _missionID } };
private _AOMarker = ((_hcDCH select 0) select 6) select 0;
if !(isNil "_AOMarker") then {
    _idx = GVAR(missionAreas) find _AOMarker;
    if !(_idx isEqualTo -1) then {
        GVAR(missionAreas) deleteAt _idx;
    };
};

// Delete from our hcDCH
GVAR(hcDCH) = GVAR(hcDCH) select { !(_x select 0 isEqualTo _profileName && { _x select 1 isEqualTo _missionID } ) };

// Remove from stopRequests
private _idx = GVAR(stopRequests) find _missionID;
if !(_idx isEqualTo -1) then {
    GVAR(stopRequests) deleteAt _idx;
};

// Remove any reinforcements
_idx = (GVAR(reinforcements) select 0) find _missionID;
if !(_idx isEqualTo -1) then {
    (GVAR(reinforcements) select 0) deleteAt _idx;
    (GVAR(reinforcements) select 1) deleteAt _idx;
};