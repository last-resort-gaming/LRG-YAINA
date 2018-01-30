/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _ret = "";
private _log = "";

if (_argStr isEqualTo "") then {
    _ret = "Please let us know what's wrong, e.g: #report Player Name - deliberate teamkilling";
    _log = "missing reason";
} else {
    // Let the user know
    _ret = "Thank you, we have logged the issue, any admins online have been notified, and the event logged for offline evaluation";
    _log = _argStr;
    // Let other admins know
    [_caller, format ["REPORT: %1", _argStr], 3] call FNC(notifyAdmins);
};

_ret remoteExecCall ["systemChat", _owner];

_log;