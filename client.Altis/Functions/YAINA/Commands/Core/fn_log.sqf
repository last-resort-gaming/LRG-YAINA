/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_caller", "_command", "_permitted", "_str"];

if (isNil "_str") then { _str = ""; };

[format ["action=%1, command=%2, uid=%3, player=%4, msg=%5", ["REJECT", "PERMIT"] select _permitted, _command, getplayerUID _caller, name _caller, _str], "CommandsLog"] call YFNC(log);