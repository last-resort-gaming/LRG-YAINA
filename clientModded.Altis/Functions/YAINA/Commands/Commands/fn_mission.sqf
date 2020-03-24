/*
Function: YAINA_CMD_fnc_mission

Description:
	Change the currently active mission to the one supplied.

Parameters:
	_owner - The owner of the player object that called this command
    _caller - The player that called this command
    _argStr - The mission we want to change to

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

if (_argStr isEqualTo "") then {
    "Usage: !mission <Mission Name> e.g: !mission MyZeus.Altis" remoteExecCall ["systemChat", _owner];
    "invalid syntax";
} else {
    // Curious case, we must log here, due to the impending restart
    [_caller, "mission", true, format["mission: %1", _argStr]] call FNC(log);
    SERVER_COMMAND_PASSWORD serverCommand format["#mission %1", _argStr];
};