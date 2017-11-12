/*
	author: Martin
	description: none
	returns: nothing
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