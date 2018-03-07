/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_units", "_prefix", ["_start", 1]];

private _grps = [];
{ _grps pushBackUnique (group _x); nil } count _units;

{
    _x setGroupIdGlobal [format ["%1_%2", _prefix, _start + _forEachIndex]];
} forEach _grps;