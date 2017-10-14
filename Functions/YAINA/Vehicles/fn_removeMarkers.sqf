/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_owner", "_markerID"];

if(SQUAD_BASED) then {
    deleteMarker _markerID;
} else {
    _markerID remoteExecCall ["deleteMarkerLocal", _owner];
};