/*
	author: Martin
	description:
	    Inspired by liberations FPS meter
	returns: nothing
*/

private _markerLocal = false;
private _source = "";
private _position  = 1;

// Only run this on server, or admin
if !(isServer || serverCommandAvailable '#kick') exitWith {};

if ( isServer ) then {
    _source = "Server";
} else {

    // if we have not got our map display yet, retry when we do
    if(isNull (findDisplay 12)) exitWith {
        [{!isNull (findDisplay 12)}, {call liberation_fnc_show_fps}, []] call CBA_fnc_waitUntilAndExecute;
    };

    if (hasInterface) then {
        _position = 0;
        _source = "local";
        _markerLocal = true;
    } else {
        if ((profileName select [0,3]) isEqualTo "HC_") then {
            _position = floor(parseNumber(profileName select [3])) + 1;
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
            _localvehicles = { local _x } count vehicles;

            _myfpsmarker setMarkerColorLocal "ColorGREEN";
            if ( _myfps < 30 ) then { _myfpsmarker setMarkerColorLocal "ColorYELLOW"; };
            if ( _myfps < 20 ) then { _myfpsmarker setMarkerColorLocal "ColorORANGE"; };
            if ( _myfps < 10 ) then { _myfpsmarker setMarkerColorLocal "ColorRED"; };

            _myfpsmarker setMarkerTextLocal format [ "%1: %2 fps, %3 units, %4 vehicles", _source, ( round ( _myfps * 100.0 ) ) / 100.0 , _localunits, _localvehicles ];

        }, 5, [_source, _myfpsmarker]] call CBA_fnc_addPerFrameHandler;

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
            _localvehicles = { local _x } count vehicles;

            _myfpsmarker setMarkerColor "ColorGREEN";
            if ( _myfps < 30 ) then { _myfpsmarker setMarkerColor "ColorYELLOW"; };
            if ( _myfps < 20 ) then { _myfpsmarker setMarkerColor "ColorORANGE"; };
            if ( _myfps < 10 ) then { _myfpsmarker setMarkerColor "ColorRED"; };

            _myfpsmarker setMarkerText format [ "%1: %2 fps, %3 units, %4 vehicles", _source, ( round ( _myfps * 100.0 ) ) / 100.0 , _localunits, _localvehicles ];

        }, 5, [_source, _myfpsmarker]] call CBA_fnc_addPerFrameHandler;
    };

};
