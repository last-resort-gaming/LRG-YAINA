/*
Function: YAINA_fnc_showFPS

Description:
    Handles initialization of the FPS meter during the postInit phase.
	Show the current FPS of the headless clients, the server and the player on the map,
    adding some coloured flair to indicate the smoothness.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin, inspired by Liberation's FPS meter
*/

#include "defines.h"

private _markerLocal = false;
private _source = "";
private _position  = 1;

if ( isServer ) then {
    _source = "Server";
} else {

    // if we have not got our map display yet, retry when we do
    if(isNull (findDisplay 12)) exitWith {
        [{!isNull (findDisplay 12)}, {call YFNC(showFPS)}, []] call CBAP_fnc_waitUntilAndExecute;
    };

    if (hasInterface) then {
        _position = 0;
        _source = "local";
        _markerLocal = true;
    } else {
        if ((profileName select [0,2]) isEqualTo "HC") then {
            _position = floor(parseNumber(profileName select [2])) + 1;
            _source = profileName;
        };
    };
};

if (_source != "") then {

    if (_markerLocal) then {
        _myfpsmarker = createMarkerLocal [ format ["localFPS%1", name player ], [ 500, 500 + (500 * _position) ] ];
        _myfpsmarker setMarkerTypeLocal "mil_start";
        _myfpsmarker setMarkerSizeLocal [ 0.7, 0.7 ];

        // Add PFH for 5 second intervals
        [{
            params ["_args", "_pfhID"];
            _args params ["_source", "_myfpsmarker"];

            _myfps = diag_fps;
            _localunits = { local _x } count allUnits;
            _localgroups = { local _x } count allGroups;
            _localvehicles = { local _x } count vehicles;

            _myfpsmarker setMarkerColorLocal "ColorGREEN";
            if ( _myfps < 30 ) then { _myfpsmarker setMarkerColorLocal "ColorYELLOW"; };
            if ( _myfps < 20 ) then { _myfpsmarker setMarkerColorLocal "ColorORANGE"; };
            if ( _myfps < 10 ) then { _myfpsmarker setMarkerColorLocal "ColorRED"; };

            _myfpsmarker setMarkerTextLocal format [ "%1: %2 fps, %3 units, %4 groups, %5 vehicles", _source, ( round ( _myfps * 100.0 ) ) / 100.0 , _localunits, _localgroups, _localvehicles ];

        }, 5, [_source, _myfpsmarker]] call CBAP_fnc_addPerFrameHandler;

    } else {
        _myfpsmarker = createMarker [ format ["fpsmarker%1", _source ], [ 500, 500 + (500 * _position) ] ];
        _myfpsmarker setMarkerType "mil_start";
        _myfpsmarker setMarkerSize [ 0.7, 0.7 ];

        // Add PFH for 5 second intervals
        [{
            params ["_args", "_pfhID"];
            _args params ["_source", "_myfpsmarker"];

            _myfps = diag_fps;
            _localunits = { local _x } count allUnits;
            _localgroups = { local _x } count allGroups;
            _localvehicles = { local _x } count vehicles;

            _myfpsmarker setMarkerColor "ColorGREEN";
            if ( _myfps < 30 ) then { _myfpsmarker setMarkerColor "ColorYELLOW"; };
            if ( _myfps < 20 ) then { _myfpsmarker setMarkerColor "ColorORANGE"; };
            if ( _myfps < 10 ) then { _myfpsmarker setMarkerColor "ColorRED"; };

            _myfpsmarker setMarkerText format [ "%1: %2 fps, %3 units, %4 groups, %5 vehicles", _source, ( round ( _myfps * 100.0 ) ) / 100.0 , _localunits, _localgroups, _localvehicles ];

        }, 5, [_source, _myfpsmarker]] call CBAP_fnc_addPerFrameHandler;
    };

};
