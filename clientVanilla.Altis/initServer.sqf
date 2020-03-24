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

// Disallow Execute Code module + Promote to Zeus
missionNamespace setVariable ["Ares_Allow_Zeus_To_Execute_Code", false, true];

[] execVM "scripts\duda123\fn_advancedUrbanRappellingInit.sqf";
[] execVM "scripts\duda123\fn_advancedRappellingInit.sqf";

// Start up logging routines
{
	["================================================", _x] call YAINA_fnc_log;
	["          YAINA is starting up....", _x] call YAINA_fnc_log;
	["================================================", _x] call YAINA_fnc_log;
} forEach ["GENERAL", "CommandsLog", "CleanupLog", "KillLog", "ErrorLog", "ArsenalLog"];

///////////////////////////////////////////////////////////
// MAP SPECIFIC SERVER SETUP
///////////////////////////////////////////////////////////
private _mapInit = missionNamespace getVariable format["YAINA_INIT_fnc_server%1", worldName];
if (!isNil "_mapInit") then { call _mapInit; };
