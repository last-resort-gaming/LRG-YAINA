/*
Function: YAINA_MM_fnc_getAOExclusions

Description:
	Get the exclusion zones in form of markers in order to avoid
	AO collision or squishing. This applies to the base protection zone
	as well as 3 radii of other existing AOs.

Parameters:
	_AOSize - The size of the AO we want exclusions for

Return Values:
	Exclusion markers for the given AO size, array of markers

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params [["_AOSize", 0]];

// This is generally used for the positioning of the objective, which could then end up _AOSize away
// therefore, to have a suitable (AO sized) gap between AOs we need to be at least 3 radius' away
// from the edge of the edge of the other objective (objective at 4 radius' away, edge of AO at 2 radius
// away, leaving a gap of 1 radius
_AOSize = _AOSize * 4;

(BASE_PROTECTION_AREAS apply { [getMarkerPos _x] + (getMarkerSize _x apply { _x + 3000 + _AOSize }) + [markerDir _x, markerShape _x == "RECTANGLE"] } )
    + (GVAR(missionAreas) apply { [getMarkerPos _x] + (getMarkerSize _x apply { _x + _AOSize }) + [markerDir _x, markerShape _x == "RECTANGLE"] } );