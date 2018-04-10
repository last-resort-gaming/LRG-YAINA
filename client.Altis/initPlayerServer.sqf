/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_player", "_didJIP"];

// We setup our admin traits here
private _uid = getPlayerUID _player;
private _cmds = [_uid, 'yaina', [], ['ALL']] call YAINA_fnc_getDBKey;

// Now...It's only a trait if it's not a command / bec command
private _serverTraits = [];
{
    private _cmd = missionNamespace getVariable format["YAINA_CMD_fnc_%1", _x];
    if (isNil "_cmd" && { !(_x in YAINA_CMD_becCommands) } ) then {
        _serverTraits pushBack toLower(_x);
    };
} forEach _cmds;

// Set the traits on the unit
_player setVariable ["YAINA_ADMIN_TRAITS", _serverTraits, true];