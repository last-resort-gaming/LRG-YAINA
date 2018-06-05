/*
Function: YAINA_fnc_getPosAround

Description:
	Return a random position that's above land a suitable distance away from the given
    position. This does not take terrain or objects into consideration, unless
    asked to do so using the custom code argument for position validation.

Parameters:
	_pos - The source position from which to search
    _min - Minimum distance (i.e. radius) from _pos for a valid position
    _max - Maximum distance (i.e. radius) from _pos for a valid position
    _code - Custom position validation code

Return Values:
	Position around the source position which satisfies our needs

Examples:
    Nothing to see here

Author:
	Martin
*/

params ["_pos", "_min", "_max", "_code"];

private _found = nil;

while ({isNil "_found"}) do {

    // Pick a random direction + distance
    _r = random 360;
    _d = _max - _min;
    _h = _min + (random _d);

    // Build position
    _x1 = (_pos select 0) + (_h * cos _r);
    _y1 = (_pos select 1) + (_h * sin _r);
    _p = [_x1, _y1, 0];

    // If position is above ground, we are good to go
    if (isNil "_code") then {
        if (!surfaceIsWater _p) then {
            _found = _p;
        };
    } else {
        if (_p call _code) then {
            _found = _p;
        };
    };
};

_found