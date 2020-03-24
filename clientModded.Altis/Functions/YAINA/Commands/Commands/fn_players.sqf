/*
Function: YAINA_CMD_fnc_players

Description:
	Find a given players (or all) and print out information
    linked to them, such as UID and name.

Parameters:
	_owner - The owner of the player object that called this command
    _caller - Not used
    _argStr - The name of the player we want to find

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _p = [_argStr] call FNC(findPlayer);
private _ret = "";

private _list = [[], []];
if (_p isEqualTo []) then {
    // Print out all UIDs and their player name
    {
        (_list select 0) pushBack (name _x);
        (_list select 1) pushBack (getPlayerUID _x);
        nil;
    } count allPlayers;
} else {
    {
        (_list select 0) pushBack (name _x);
        (_list select 1) pushBack (getPlayerUID _x);
        nil;
    } count _p;
};

private _sorted = (_list select 0) + [];
_sorted sort true;

{
    _idx = (_list select 0) find _x;
    if !(_idx isEqualTo -1) then {
        format ["%1 - %2", (_list select 1) select _idx, _x] remoteExec ["systemChat", _owner]
    };
    nil
} count _sorted;

""