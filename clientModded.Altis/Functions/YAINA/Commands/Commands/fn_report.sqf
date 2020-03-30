/*
Function: YAINA_CMD_fnc_report

Description:
	Report an issue, a player or anything else to the server logs 
    and currently logged in admins.

Parameters:
	_owner - The owner of the player object that called this command
    _caller - The player that called this command
    _argStr - The player and/or reasons we want to report/for reporting

Return Values:
	Compiled message for internal handling

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _ret = "";
private _log = "";

if (_argStr isEqualTo "") then {
    _ret = "Please let us know what's wrong, e.g: !report Player Name - deliberate teamkilling";
    _log = "missing reason";
} else {
    // Let the user know
    _ret = "Thank you, we have logged the issue, any admins online have been notified, and the event logged for offline evaluation";
    _log = _argStr;
    // Let other admins know
    [_caller, format ["REPORT: %1", _argStr], 2] call FNC(notifyAdmins);
};

_ret remoteExecCall ["systemChat", _owner];

_log;