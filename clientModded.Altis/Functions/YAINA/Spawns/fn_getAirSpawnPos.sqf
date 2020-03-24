/*
Function: YAINA_SPAWNS_fnc_getAirSpawnPos

Description:
	Finds a place at the edge of the map closest to a given position.

Parameters:
	_pos - The position from which we want the edge positions

Return Values:
	Point at the edge of the map as a 2D position

Examples:
    Nothing to see here

Author:
	Martin
*/

params ["_pos"];

// Initial Fuzzy Return, now we just move
// one of the coords to cloest side
private _ret  = [
    (_pos select 0) - 3000 + random 6000,
    (_pos select 1) - 3000 + random 6000
];

// See if we have encountered a natural edge
private _foundEdge = false;
if (_ret select 0 >= worldSize) then {
    _ret set [0, worldSize - 100];
    _foundEdge = true;
} else {
    if(_ret select 0 <= 0) then {
        _ret set[0, 100];
        _foundEdge = true;
    };
};

if (_ret select 1 >= worldSize) then {
    _ret set [1, worldSize - 100];
    _foundEdge = true;
} else {
    if(_ret select 1 <= 0) then {
        _ret set[1, 100];
        _foundEdge = true;
    };
};

// Short out here if we have already got an edge
if (_foundEdge) exitWith {
    _ret;
};

// Normalize distances to pick closest
private _hsz = worldSize / 2;
private _dx  = +_ret;
private _dxi = [false, false];
if (_ret select 0 > _hsz) then {
    _dx set [0, worldSize - (_ret select 0)];
    _dxi set [0, true];
};

if (_ret select 1 > _hsz) then {
    _dx set [1, worldSize - (_ret select 1)];
    _dxi set [1, true];
};

// pick the min dist, and move that edge to side
private _min = (_dx select 0) min (_dx select 1);
private _side = _dx find _min;

if (_dxi select _side) then {
    _ret set [_side, worldSize - 100];
} else {
    _ret set [_side, 100];
};

_ret;