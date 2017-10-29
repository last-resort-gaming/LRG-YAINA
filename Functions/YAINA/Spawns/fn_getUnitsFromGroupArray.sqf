/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_groups"];

private _units = [];
{ _units append (units _x); true; } count _groups;
_units;