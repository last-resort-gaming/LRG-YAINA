/*
Function: YAINA_METRICS_fnc_postInit

Description:
	Handles initialization of the metrics system during the postInit
    phase. Mainly concerned with getting A3Graphite set up and adding
    the per-frame event handler for sending the required information
    the graphite.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

if !(isServer || !hasInterface) exitWith {};
if !(isClass(configFile >> "CfgPatches" >> "a3graphite")) exitWith {};
if (isNil "A3GRAPHITE_PREFIX") exitWith {};


// Every 10 seconds we send metrics
[{

    // Number of local units
    ["count.units", { local _x } count allUnits] call FNC(send);
    ["count.groups", { local _x } count allGroups] call FNC(send);
    ["count.vehicles", { local _x} count vehicles] call FNC(send);

    // Server Stats
    ["stats.fps", diag_fps] call FNC(send);
    ["stats.fpsMin", diag_fpsMin] call FNC(send);
    ["stats.uptime", diag_tickTime] call FNC(send);
    ["stats.missionTime", time] call FNC(send);

    // Scripts
    _s = diag_activeScripts;
    ["scripts.spawn", _s select 0] call FNC(send);
    ["scripts.execVM", _s select 1] call FNC(send);
    ["scripts.exec", _s select 2] call FNC(send);
    ["scripts.execFSM", _s select 3] call FNC(send);
    ["scripts.pfh", count CBAP_perFrameHandlerArray] call FNC(send);

    // Globals if server
    if (isServer) then {
        // Number of local units
        ["count.units", count allUnits, true] call FNC(send);
        ["count.groups", count allGroups, true] call FNC(send);
        ["count.vehicles", count vehicles, true] call FNC(send);
        ["count.players", count allPlayers, true] call FNC(send);
    };

}, 10, []] call CBAP_fnc_addPerFrameHandler;