/*
	author: Martin
	description: none
	returns: [groups, vehicles]

*/
#include "..\defines.h"

#define INF_TEAMS "OIA_InfTeam","OIA_InfTeam_AT","OIA_InfTeam_AA","OI_reconPatrol","OIA_GuardTeam"
#define VEH_TYPES "O_MBT_02_cannon_F","O_APC_Tracked_02_cannon_F","O_APC_Wheeled_02_rcws_F","O_MRAP_02_gmg_F","O_MRAP_02_hmg_F","O_APC_Tracked_02_AA_F"

params ["_missionID", "_center", "_radius",
        ["_garrisons", 1],
        ["_garrisonDist", [0,60]],
        ["_infMin", 3],
        ["_sniperMin", 1],
        ["_vehMin", 2],
        ["_aaMin", 1],
        ["_infRand", 4],
        ["_sniperRand", 0],
        ["_vehRand", 0],
        ["_aaRand", 0]
       ];

private ["_x","_g","_pos","_flatPos","_rpos","_v"];

// Simple protection for broken requests
if (_center isEqualTo [0,0]) exitWith {};

// Prep return values
private _groups = [];
private _vehicles = [];

///////////////////////////////////////////////////////////
// GARRISONS
///////////////////////////////////////////////////////////

private _garrisonedGroups = ([_center, _garrisonDist, _garrisons] call FNC(infantryGarrison));
{ _groups pushBack _x; _x setGroupIdGlobal [format["%1_gar%2", _missionID, _forEachIndex]]; } forEach _garrisonedGroups;

///////////////////////////////////////////////////////////
// INFANTRY
///////////////////////////////////////////////////////////

if !((_infMin + _infRand) isEqualTo 0) then {
    for "_x" from 0 to (((_infMin-1) max 0) + floor(random (_infRand+1))) do {
        _rpos = [[[_center, _radius],[]],["water","out"]] call BIS_fnc_randomPos;
        _g = [_rpos, EAST, (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> [INF_TEAMS] call BIS_fnc_selectRandom)] call BIS_fnc_spawnGroup;
        _g setGroupIdGlobal [format["%1_inf%2", _missionID, _x]];
        [_g, _center, _radius/1.5] call CBAP_fnc_taskPatrol;
        [_g, 2] call FNC(setUnitSkill);
        _groups pushBack _g;
    };
};

///////////////////////////////////////////////////////////
// SNIPER TEAMS
///////////////////////////////////////////////////////////
if !((_sniperMin + _sniperRand) isEqualTo 0) then {
    for "_x" from 0 to (((_sniperMin-1) max 0) + floor(random (_sniperRand+1))) do {
        _rpos = [_center, _radius, 100, 20] call BIS_fnc_findOverwatch;
        _g = [_rpos, east, (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OI_SniperTeam")] call BIS_fnc_spawnGroup;
        _g setGroupIdGlobal [format["%1_sniper%2", _missionID, _x]];
        _g setBehaviour "COMBAT";
        _g setCombatMode "RED";
        [_g, 3] call FNC(setUnitSkill);
        _groups pushBack _g;
    };
};

///////////////////////////////////////////////////////////
// STD VEHICLES
///////////////////////////////////////////////////////////

if !((_vehMin + _vehRand) isEqualTo 0) then {
    for "_x" from 0 to (((_vehMin-1) max 0) + floor(random (_vehRand+1))) do {

        _g = createGroup east;
        _g setGroupIdGlobal [format ["%1_Veh%2", _missionID, _x]];

        _rpos = [[[_center, _radius],[]],["water","out"]] call BIS_fnc_randomPos;
        _v = [VEH_TYPES] call BIS_fnc_selectRandom createVehicle _rpos;
        _v lock 3;

        [_v, _g] call BIS_fnc_spawnCrew;
        [_g, _center, _radius/2] call CBAP_fnc_taskPatrol;
        [_g, 3] call FNC(setUnitSkill);
        if (random 1 >= 0.5) then { _v allowCrewInImmobile true; };

        _groups pushBack _g;
        _vehicles pushBack _v;
    };
};

///////////////////////////////////////////////////////////
// TIGRIS
///////////////////////////////////////////////////////////

if !((_aaMin + _aaRand) isEqualTo 0) then {
    for "_x" from 0 to (((_aaMin-1) max 0) + floor(random (_aaRand+1))) do {

        _g = createGroup east;
        _g setGroupIdGlobal [format ["%1_VehAA%2", _missionID, _x]];

        _rpos = [[[_center, _radius],[]],["water","out"]] call BIS_fnc_randomPos;
        _v = "O_APC_Tracked_02_AA_F" createVehicle _rpos ;
        _v lock 3;

        [_v, _g] call BIS_fnc_spawnCrew;
        [_g, _center, _radius / 2] call CBAP_fnc_taskPatrol;
        [_g, 4] call FNC(setUnitSkill);
        if (random 1 >= 0.5) then { _v allowCrewInImmobile true; };

        _groups pushBack _g;
        _vehicles pushBack _v;
    };
};

[_groups, _vehicles]