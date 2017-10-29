/*
	author: Martin
	description:
	    Return a random position that's above land a suitable distance
	    from the given location, when you don't really care how messy
	    it is, and works nicer over larger areas than findSafePos
	args:
	    _pos:  position from which to search
	    _min:  minimum radius from _pos to permit result
	    _max:  maximum radius from _pos to permit resuls
	    _code: code to validate position
	returns:
	    position
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