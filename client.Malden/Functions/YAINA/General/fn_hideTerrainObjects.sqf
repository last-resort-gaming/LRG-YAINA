/*
	author: Martin
	description:
	    Hides terrain objects, similar to that of ModuleHideTerrain_F in 3DEN
	    And to avoid the issue of exploding buildings re-appearing, we set them
	    to not take damage.
	returns:
	    nil
*/

#include "defines.h"

params ["_oid", "_key", "_pos", "_radius", ["_excludes", []], ["_types", CATEGORIES, [[]]]];

if(!isServer) exitWith {
    _this remoteExec [QYFNC(hideTerrainObjects), 2];
};

// This is a bit shit, so we either want remoteExsecutedOwner to be 2, or 0
// as headless clients come up as 0, along with false on isRemoteExecuted.
if !( remoteExecutedOwner isEqualTo 2 || { remoteExecutedOwner isEqualTo 0 }) exitWith {};
if (_oid isEqualTo 0 && { isMultiplayer }) exitWith {};

private _clearTypes  = [];
{
    _id = CATEGORIES find _x;
    if (_id isEqualTo -1) exitWith { _clearTypes pushBackUnique _x; };
    {
        _clearTypes pushBackUnique _x;
        true;
    } count (CATEGORY_COMP select _id);
} forEach _types;

private _hide = nearestTerrainObjects [_pos, _clearTypes, _radius, false, true];

{
    if !(_x in _excludes) then {
        _x hideObjectGlobal true;
        _x allowDamage false;
    };
    true;
} count _hide;

private _idx = (YVAR(hiddenTerrainObjects) select 0) find _key;
if (_idx isEqualTo -1) then {
    (YVAR(hiddenTerrainObjects) select 0) pushBack _key;
    (YVAR(hiddenTerrainObjects) select 1) pushBack [_hide];
} else {
    ((YVAR(hiddenTerrainObjects) select 1) select _idx) pushBack _hide;
};

// Give the client the key to say it's been done
if !(_oid isEqualTo 2) then {
    [_key, {
        missionNamespace setVariable[_this, true];
    }] remoteExec ["call", _oid];
} else {
    missionNamespace setVariable [_key, true];
};

nil