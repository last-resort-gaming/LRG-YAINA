/*
Function: YAINA_fnc_setDBKey

Description:
	Writes the passed value to the given key of given database section.
    Database used is iniDB.
    For information on sections and keys, see:
    https://github.com/Uro1/-inidbi

Parameters:
	_section - The section of the database we want to write to
    _key  - The key we want to write to
    _value - The value to write to the key, must be one of type string/scalar/array/bool

Return Values:
	true if is write was successfull, false if not

Examples:
    Nothing to see here

Author:
	Mokka
*/

#include "defines.h"

params ["_section", "_key", "_value"];

private _ret = nil;

if (isClass(configFile >> "CfgPatches" >> "inidbi2")) then {
    if (isNil QYVAR(inidbi)) then {
        YVAR(inidbi) = ["new", "yaina"] call OO_INIDBI;
    };

    if ("exists" call YVAR(inidbi)) then {
        _ret = ["write", [_section, _key, _value]] call YVAR(inidbi);
    };
};

if (isNil "_ret") exitWith {
    false;
};

_ret