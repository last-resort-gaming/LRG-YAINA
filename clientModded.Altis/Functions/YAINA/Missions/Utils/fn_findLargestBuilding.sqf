/*
Function: YAINA_MM_fnc_findLargestBuilding

Description:
	Find the largest building and the positions in the building
	in a certain radius around a given position.

Parameters:
	_pos - The source position around which to find the largest building
	_radius - The search radius around the position

Return Values:
	Array containing the following information:

	_building - The largest building found
	_positions - The positions inside that building for occupation

Examples:
    Nothing to see here

Author:
	Martin
*/

params ["_pos", "_radius"];

private _a = [[],[],[]];

_a set [0, nearestObjects [_pos, ["HOUSE", "BUILDING"], _radius] select { !(isObjectHidden _x) }];
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