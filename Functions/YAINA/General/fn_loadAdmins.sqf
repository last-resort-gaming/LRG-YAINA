/*
	author: Martin
	description: none
	returns: nothing

	0 = everyone
	1 = HQ
    2 = Medium
    3 = Everything

*/

#include "defines.h"

if !(isServer) exitWith {};

if (isNil QVAR(loadAdmins)) then {
    if (isClass(configFile >> "CfgPatches" >> "inidbi2")) then {
        call compile preProcessFile "\inidbi2\init.sqf";
        GVAR(loadAdmins) = 1;
    } else {
        ["localAdmins: inidbi2 not loaded, dynamic admin levels disabled"] call YFNC(log);
        GVAR(loadAdmins) = 0;
    };
};

if (GVAR(loadAdmins) isEqualTo 0) then {
    GVAR(admins) = [
        ["76561197981494016"],
        [3]
    ];
} else {

    GVAR(inidbi) = ["new", "yaina"] call OO_INIDBI;
    if ("exists" call GVAR(inidbi)) then {
        GVAR(admins) = ["read", ["general", "admins", [[],[]]]] call GVAR(inidbi);
    } else {
        GVAR(admins) = [];
    };

    if (((GVAR(admins) select 0) find "76561197981494016") isEqualTo -1) then {
        (GVAR(admins) select 0) pushBack "76561197981494016";
        (GVAR(admins) select 1) pushBack 3;
    };
};