/*
Function: YAINA_CMD_fnc_zeuslist

Description:
	Print out the current list of players with temporary Zeus access.
    Temporary Zeus access is granted through zeusadd.

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
    _list pushBack format ["%1 - %2", (YVAR(zeuslist) select 1) select _forEachIndex, _x];
    true;
} forEach (YVAR(zeuslist) select 0);

// Sort the list and output it
if (_list isEqualTo []) then {
    _list pushBack "There are no zeus users with temporary zeus";
} else {
    _list sort true;
};

{ _x remoteExec ["systemChat", _owner]; true; } count _list;

""