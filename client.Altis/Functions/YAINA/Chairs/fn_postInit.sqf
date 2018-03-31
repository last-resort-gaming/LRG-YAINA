/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

{
    _marker    = _x;
    _markerPos = getMarkerPos _x;
    _markerSz  = getMarkerSize _x;
    _markerMax = (_markerSz select 0) max (_markerSz select 1);
    {
        if (_x inArea _marker) then {
            [_x] call FNC(initChair);
        };
        nil;
    } count (_markerPos nearObjects ["Land_CampingChair_V2_F", _markerMax]);
    nil;
} count BASE_PROTECTION_AREAS;