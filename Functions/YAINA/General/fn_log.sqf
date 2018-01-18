/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_message", ["_log", "GENERAL"]];

#include "defines.h"

if (isNil QYVAR(A3Log)) then {
    YVAR(A3Log) = isClass(configFile >> "CfgPatches" >> "a3log");
};

if (YVAR(A3Log)) then {
    [_message, _log] call A3Log;
} else {
    diag_log format ["%1 | %2", _log, _message];
};
