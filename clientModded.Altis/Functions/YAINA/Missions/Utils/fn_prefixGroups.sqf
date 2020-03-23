/*
Function: YAINA_MM_fnc_prefixGroups

Description:
	Sets global group IDs of spawned units for easy identification
	on all machines.

Parameters:
	_units - The units to combine into a group
	_prefix - The prefix for identifying the group
	_start - The starting index of the IDs

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

params ["_units", "_prefix", ["_start", 1]];

private _grps = [];
{ _grps pushBackUnique (group _x); nil } count _units;

{
    _x setGroupIdGlobal [format ["%1_%2", _prefix, _start + _forEachIndex]];
} forEach _grps;