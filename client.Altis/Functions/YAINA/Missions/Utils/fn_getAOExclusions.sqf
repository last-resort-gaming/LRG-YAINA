/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params [["_AOSize", 0]];

// This is generally used for the positioning of the objective, which could then end up _AOSize away
// therefore, to have a suitable (AO sized) gap between AOs we need to be at least 3 radius' away
// from the edge of the edge of the other objective (objective at 4 radius' away, edge of AO at 2 radius
// away, leaving a gap of 1 radius
_AOSize = _AOSize * 4;

(BASE_PROTECTION_AREAS apply { [getMarkerPos _x, (getMarkerSize _x apply { _x + 3000 + _AOSize }) + [markerDir _x, markerShape _x == "RECTANGLE"] ] } )
    + (GVAR(missionAreas) apply { [getMarkerPos _x, (getMarkerSize _x apply { _x + _AOSize }) + [markerDir _x, markerShape _x == "RECTANGLE"] ] } );