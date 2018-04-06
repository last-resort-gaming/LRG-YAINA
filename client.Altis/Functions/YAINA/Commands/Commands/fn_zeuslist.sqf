/*
	author: Martin
	description: none
	returns: nothing
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