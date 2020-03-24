/*
Function: YAINA_MM_fnc_setupParadrop

Description:
	Sets up the paradrop functionality for a newly created AO, allowing
    players to deploy to this AO if there are no transport
    pilots available.

Parameters:
	_missionMarker - Reference marker of the AO location

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h";

params ["_missionMarker"];

if(!isServer) then {
    [_missionMarker] remoteExecCall [QFNC(setupParadrop), 2];
} else {

    // We do the cleanup here because it's easier than doing it on each
    // client and since we'll most likely be removing before adding its easy
    private _newParadropMarkers = [];
    {
        if  !(isNil "_x" ) then {
            if !((getMarkerPos _x) isEqualTo [0,0,0]) then {
                _newParadropMarkers pushBack _x;
            };
        };
    } forEach GVAR(paradropMarkers);

    _newParadropMarkers pushBack _missionMarker;

    GVAR(paradropMarkers) = _newParadropMarkers;
    publicVariable QVAR(paradropMarkers);
};