/*
Function: YAINA_fnc_getDBKey

Description:
	Returns the value stored in the given key of given database section.
    Database used is iniDB.
    For information on sections and keys, see:
    https://github.com/Uro1/-inidbi

Parameters:
	_section - The section of the database we want to read from
    _key  - The key we want to read out
    _default - The default value to return if key empty or not found
    _defaultLocal - If running on local server (self-hosted)

Return Values:
	The value stored in the key, or default value

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_section", "_key", "_default", "_defaultLocal"];

private _ret = nil;

if (isServer && hasInterface && { !(isNil "_defaultLocal") } ) then {
    _default = _defaultLocal;
};

if (isClass(configFile >> "CfgPatches" >> "inidbi2")) then {
    if (isNil QYVAR(inidbi)) then {
        YVAR(inidbi) = ["new", "yaina"] call OO_INIDBI;
    };

    if ("exists" call YVAR(inidbi)) then {
        _ret = ["read", [_section, _key, _default]] call YVAR(inidbi);
    };
};

if (isNil "_ret") exitWith {
    _default;
};

_ret