/*
Function: YAINA_VEH_fnc_getMarkers

Description:
	Returns an array of all markers that mark the location of an 
    owned vehicle that fit the search prefix.

Parameters:
	_prefix - The search prefix, empty for all

Return Values:
	Array of markers satisfying the search condition

Examples:
    Nothing to see here

Author:
	Martin
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