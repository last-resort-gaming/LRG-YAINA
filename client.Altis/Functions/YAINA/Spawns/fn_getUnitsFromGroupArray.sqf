/*
Function: YAINA_SPAWNS_fnc_getUnitsFromGroupArray

Description:
	Return all units in the groups passed as an array combined in one
	single array.

Parameters:
	_groups - Array of groups which unit's we want

Return Values:
	Array containing all units in the groups passed

Examples:
    Nothing to see here

Author:
	Martin
*/

params ["_groups"];

private _units = [];
{ _units append (units _x); true; } count _groups;
_units;