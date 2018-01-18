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

if (isNil QYVAR(loadAdmins)) then {
    if (isClass(configFile >> "CfgPatches" >> "inidbi2")) then {
        YVAR(loadAdmins) = 1;
    } else {
        ["localAdmins: inidbi2 not loaded, dynamic admin levels disabled"] call YFNC(log);
        YVAR(loadAdmins) = 0;
    };
};

if (YVAR(loadAdmins) isEqualTo 0) then {
    YVAR(admins) = [
        ["76561197981494016"],
        [3]
    ];
} else {

    YVAR(inidbi) = ["new", "yaina"] call OO_INIDBI;
    if ("exists" call YVAR(inidbi)) then {
        YVAR(admins) = ["read", ["general", "admins", [[],[]]]] call YVAR(inidbi);
    } else {
        YVAR(admins) = [[],[]];
    };

    if (((YVAR(admins) select 0) find "76561197981494016") isEqualTo -1) then {
        (YVAR(admins) select 0) pushBack "76561197981494016";
        (YVAR(admins) select 1) pushBack 3;
    };

};