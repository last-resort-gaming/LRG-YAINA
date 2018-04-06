/*
	author: Martin
	description: none
	returns: nothing
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