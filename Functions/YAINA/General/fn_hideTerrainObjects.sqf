/*
	author: Martin
	description:
	    Hides terrain objects, similar to that of ModuleHideTerrain_F in 3DEN
	    And to avoid the issue of exploding buildings re-appearing, we set them
	    to not take damage.
	returns:
	    List of objects hidden, useful to pass into showTerrainObjects!
*/

#include "defines.h"

params ["_pos", "_radius", ["_types", CATEGORIES, [[]]]];


_clearTypes  = [];
{
    _id = CATEGORIES find _x;
    if (_id isEqualTo -1) exitWith { _clearTypes pushBackUnique _x; };
    {
        _clearTypes pushBackUnique _x;
        true;
    } count (CATEGORY_COMP select _forEachIndex);
} forEach _types;

_hide = nearestTerrainObjects [_pos, _clearTypes, _radius, false, true];

{
    _x hideObjectGlobal true;
    _x allowDamage false;
    true;
} count _hide;

_hide;