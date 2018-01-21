/*
	author: Martin
	description: none
	returns: [building, positions] if found, else []
*/

params ["_pos", "_radius"];

private _a = [[],[],[]];

_a set [0, nearestObjects [_pos, ["HOUSE"], _radius]];
if ((_a select 0) isEqualTo []) exitWith { [] };

// Work out the positions and the number of them
_a set [1, (_a select 0) apply { _x call BIS_fnc_buildingPositions }];
_a set [2, (_a select 1) apply { count _x }];

// Sort the pos count, and get the index of the largest one
private _s  = [_a select 2, [],{_x}, "DESCEND"] call BIS_fnc_sortBy;
private _idx = (_a select 2) find (_s select 0);
if (_idx isEqualTo -1) exitWith { [] };

// Return the building and building positions
[(_a select 0) select _idx, (_a select 1) select _idx]