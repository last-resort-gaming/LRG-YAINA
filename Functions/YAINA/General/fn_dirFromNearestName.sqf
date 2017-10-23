

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