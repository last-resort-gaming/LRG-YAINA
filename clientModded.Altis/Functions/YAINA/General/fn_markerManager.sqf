/*
Function: YAINA_fnc_markerManager

Description:
	Initializes the marker manager during the postInt phase.
    Prefixes the creator's name to the marker on command channel,
    delete user-created markers on the global channel.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

if (!isServer) exitWith {};

[{
    // Loop through all user defined markers
    // If they are in command, prefix user name to text
    // If they are in global, delete
    {
        _markerInfo = (_x select [15] splitString "/");

        // Delete from Global
        if (_markerInfo select 2 isEqualTo "0") then {
            deleteMarker _x;
        } else {
            // Only continue if alpha isn't already set
            if !((markerAlpha _x) isEqualTo 0.99) then {

                // If it's in command or side, delete POLYLINES, and prefix rest with owners name
                if ((_markerInfo select 2) in ["1", "2"]) then {

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
