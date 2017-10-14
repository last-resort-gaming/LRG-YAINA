/*
	author: Martin
	description: none
	returns: nothing
*/


// Dyanmic Groups
["Initialize"] call BIS_fnc_dynamicGroups;

// Setup some Global Vars
CBA_display_ingame_warnings = false;
publicVariable "CBA_display_ingame_warnings";

// Start our managers
if (("TimeManagerEnable" call BIS_fnc_getParamValue) isEqualTo 1) then { call YAINA_fnc_timeManager; };

// Setup our vehicles
{ [_x, true, 30] call YAINA_VEH_fnc_initVehicle; } count [
    hh1_0,
    hh1_1,
    hh1_2,
    hh1_3,
    hh1_4,
    hh1_5,
    hh3,
    hh4,
    gg3
];

g1 setPylonLoadOut [1, "PylonRack_Bomb_GBU12_x2", true, [0]];
g1 setPylonLoadOut [2, "PylonRack_Bomb_GBU12_x2", true, [0]];

// Setup our vehicles
{ [_x, false, 30, 0] call YAINA_VEH_fnc_initVehicle; } count [
    s1,
    s2,
    g1
];
