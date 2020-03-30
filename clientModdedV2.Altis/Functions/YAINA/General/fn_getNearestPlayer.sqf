/*
Function: YAINA_fnc_getNearestPlayer

Description:
	Get the player nearest to the given position.

Parameters:
	_src - The position to which we want the nearest player

Return Values:
	Array containing the following information:

    _retplayer - The player nearest to the given position
    _retdist - The direction vector between the nearest player and the source position

Examples:
    Nothing to see here

Author:
	Martin
*/

params ["_src"];

private _retdist = -1;
private _retplayer = objNull;

{
    _d = _x distance2D _src;
    if (_d < _retdist || { _retdist isEqualTo -1 }) then {
        _retplayer = _x;
        _retdist   = _d;
    };
    nil;
} count allPlayers;

[_retplayer, _retdist]