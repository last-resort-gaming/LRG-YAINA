/*
Function: YAINA_MM_fnc_delHCDCH

Description:
	Deletes a mission from the headless client failover handler.
    Removes reinforcements, markers and from stop requests.

Parameters:
	_profileName - The profile name of the headless client
    _missionID - The ID of the mission we want to remove

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
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
        publicVariable QVAR(missionAreas);
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