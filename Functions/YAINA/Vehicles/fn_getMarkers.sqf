/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_prefix"];
private _markers = [];
private _prefixLen = count _prefix;

{
    if (_x select [0,_prefixLen] isEqualTo _prefix) then {
        _markers pushBack _x;
    };
    true
} count allMapMarkers;

_markers;