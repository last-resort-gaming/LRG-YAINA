/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if (!isServer) exitWith {};

[{
    // Loop through all user defined markers
    // If they are in command, prefix user name to text
    // If they are in global, delete
    {
        _markerInfo = (_x select [15] splitString "/");
        diag_log format ["Marker Info: %1", _markerInfo];

        // Delete from Global/Side
        if (_markerInfo select 2 in ["0","1"]) then {
            deleteMarker _x;
        } else {
            // Only continue if alpha isn't already set
            if !((markerAlpha _x) isEqualTo 0.99) then {

                // If it's in command, delete POLYLINES, and prefix rest with owners name
                if ((_markerInfo select 2) isEqualTo "2") then {

                    if (markerShape _x isEqualTo "POLYLINE") then {
                        deleteMarker _x;
                    } else {
                        _idx = (YAINA_ownerIDs select 0) find (parseNumber (_markerInfo select 0));

                        if !(_idx isEqualTo -1) then {
                            _x setMarkerText format["%1: %2", ((YAINA_ownerIDs select 1) select _idx) select 1, markerText _x];
                        };
                    };
                };

                // Always set the alpha, so we don't waste time looking up missing owners
                _x setMarkerAlpha 0.99;
            };
        };
        true;
    } count (allMapMarkers select { _x select [0,15] isEqualTo "_USER_DEFINED #" });

}, 2, []] call CBA_fnc_addPerFrameHandler;
