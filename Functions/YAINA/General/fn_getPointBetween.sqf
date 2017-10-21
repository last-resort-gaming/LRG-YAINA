/*
	author: Martin
	description:
	    Gives the position of a point at distance _dst
	    from _fp to _tp
	returns: Position 2D
*/

params ["_fp", "_tp", "_dst"];

private _theta = _fp getDir _tp;
private _range = _fp distance2D _tp;

private _d = _range - _dst;

if (_d < 0) exitWith { _tp; };

[
    (_fp select 0) + _d * sin _theta,
    (_fp select 1) + _d * cos _theta
];
