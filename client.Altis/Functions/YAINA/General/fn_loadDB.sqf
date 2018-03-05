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

YVAR(admins)   = [[],[]];
YVAR(zeuslist) = [[],[]];

if (isClass(configFile >> "CfgPatches" >> "inidbi2")) then {
    YVAR(inidbi) = ["new", "yaina"] call OO_INIDBI;
    if ("exists" call YVAR(inidbi)) then {
        YVAR(admins)   = ["read", ["general", "admins", [[],[]]]] call YVAR(inidbi);
        YVAR(zeuslist) = ["read", ["general", "zeuslist", [[],[]]]] call YVAR(inidbi);
    };
} else {
    ["localAdmins: inidbi2 not loaded, dynamic admin levels disabled"] call YFNC(log);
};

// If we are a server and interface, then add myself as admin (running in eden/locally)
if(isServer && hasInterface) then {
    (YVAR(admins) select 0) pushBack (getPlayerUID player);
    (YVAR(admins) select 1) pushBack 0;
};
