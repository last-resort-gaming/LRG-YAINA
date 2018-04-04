/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_section", "_key", "_default", "_defaultLocal"];

private _ret = nil;

if (isServer && hasInterface && { !(isNil "_defaultLocal") } ) then {
    systemChat "setting default to localdefault";
    _default = _defaultLocal;
};

if (isClass(configFile >> "CfgPatches" >> "inidbi2")) then {

    systemChat "got inidb2";

    if (isNil QYVAR(inidbi)) then {
        YVAR(inidbi) = ["new", "yaina"] call OO_INIDBI;
    };

    if ("exists" call YVAR(inidbi)) then {
        _ret = ["read", [_section, _key, _default]] call YVAR(inidbi);
    };
};

if (isNil "_ret") exitWith {
    systemChat "returning default";
    _default;
};

systemChat "returning ret";
_ret