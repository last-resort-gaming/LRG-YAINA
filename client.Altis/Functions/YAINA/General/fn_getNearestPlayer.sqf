/*
	author: Martin
	description: none
	returns: nothing
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