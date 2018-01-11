/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_caller", "_command", "_permitted", "_str"];

private _pad  = (GVAR(cmdMax) - (count _command)) max 0;
private _pads = "";

for "_i" from 0 to _pad do { _pads = _pads + " "; };

[format ["%1 | %2%3 | %4 | %5 | %6", ["REJECT", "PERMIT"] select _permitted, _command, _pads, getplayerUID _caller, name _caller, _str], "CommandsLog"] call YFNC(log);