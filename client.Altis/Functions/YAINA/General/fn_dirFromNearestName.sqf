/*
Function: YAINA_fnc_dirFromNearestName

Description:
	Returns the closest town, direction to the town and the
    town's description from a given position.

Parameters:
	_pos - The position to which we want the nearest town and heading

Return Values:
	Array containing the following information:

    _closestTown - The town nearest to the given position
    _closestTownDir _ The heading from the given position to the found town
    _closestTownDesc - The description of the found town (if available)

Examples:
    Nothing to see here

Author:
	(presumably) Martin
*/

params ["_pos"];

_closestTown     = nearestLocations [_pos, ["Name", "NameCity", "NameCityCapital", "NameVillage"], worldSize, _pos] select 0;
_closestTownDir  = [position _closestTown, _pos] call BIS_fnc_dirTo;

_closestTownDesc = _closestTownDir call {
    _d = _this - 11.25;

    _posArray = ["north", "north north east", "north east", "east north east", "east",
                 "east south east", "south east", "south south east", "south",
                 "south south west", "south west", "west south west", "west",
                 "west north west", "north west", "north north west", "north"];

    _posID = 0;
    while {_d > 0} do {
        _posID = _posID + 1;
        _d = _d - 22.5;
    };
    _posArray select _posID;
};

[_closestTown, _closestTownDir, _closestTownDesc];