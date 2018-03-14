/*
	author: Martin
	description: none
	returns: nothing
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