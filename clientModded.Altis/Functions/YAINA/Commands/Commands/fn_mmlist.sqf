/*
Function: YAINA_CMD_fnc_mmlist

Description:
	Display a list of all currently running missions.

Parameters:
	_owner - The owner of the player object that called this command
    _caller - Not used
    _argStr - Not used

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _list = [];

{
    _list pushBack format ["%1 - %2", _x select 1, _x select 4];
    true;
} count (YAINA_MM_hcDCH select { !(_x select 2 isEqualTo "CLEANUP") });

// Sort the list and output it
if (_list isEqualTo []) then {
    _list pushBack "There are no missions currently running";
} else {
    _list sort true;
};


{ _x remoteExec ["systemChat", _owner]; true; } count _list;

""