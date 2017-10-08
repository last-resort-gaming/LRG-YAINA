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
{
    [_x, true, 0] call YAINA_VEH_fnc_initVehicle;
} count [
    hh1_0,
    hh1_1,
    hh1_2,
    hh1_3,
    hh1_4,
    hh1_5
];