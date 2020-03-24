/*
Function: YAINA_fnc_getPointBetween

Description:
	Gives the position of a point a certain distance between two points, _fp and _tp.

Parameters:
	_fp - The source position
	_tp - The destination position
	_dst - The distance of the point from _fp to _tp

Return Values:
	Point at _dst between _fp and _tp as a 2D position

Examples:
    Nothing to see here

Author:
	Martin
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
