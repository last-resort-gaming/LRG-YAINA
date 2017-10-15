/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_profileName", "_missionID"];

// Delete from our hcDCH
GVAR(hcDCH) = GVAR(hcDCH) select { !(_x select 0 isEqualTo _profileName && _x select 1 isEqualTo _missionID) };

// Remove from hcBuildingRestores
_brID = (GVAR(hcBuildingRestores) select 0) find _missionID;
if !(_brID isEqualTo -1) then {
    (GVAR(hcBuildingRestores) select 0) deleteAt _brID;
    (GVAR(hcBuildingRestores) select 1) deleteAt _brID;
};


