/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_message", ["_log", "GENERAL"]];

#include "defines.h"

if (isNil QVAR(A3Log)) then {
    GVAR(A3Log) = isClass(configFile >> "CfgPatches" >> "a3log");
};

if (GVAR(A3Log)) then {
    [_message, _log] call A3Log;
} else {
    diag_log format ["%1 | %2", _log, _message];
};
