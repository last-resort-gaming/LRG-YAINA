/*
Function: YAINA_MM_fnc_addHCDCH

Description:
	Adds the Headless Clients to the disconnect handling routine.
	Also extracts a mission's position and pushes that back to AO Exclusions.

Parameters:
	_this - PFH reference data, see YAINA_MM_fnc_startMissionPFH

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

if(!isServer) exitWith {};

GVAR(hcDCH) pushBack _this;

// As only the server knows what mission is where, we take the first
// Marker (the area marker, as used for cleanup) and add it to the
// list of Area Exclusions
private _AOMarker = (_this select 6) select 0;

if !(getMarkerPos _AOMarker isEqualTo [0,0,0]) then {
    GVAR(missionAreas) pushBack _AOMarker;
    publicVariable QVAR(missionAreas);
};