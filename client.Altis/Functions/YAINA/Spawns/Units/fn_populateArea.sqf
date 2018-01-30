/*
	author: Martin
	description: none
	returns: [groups, vehicles]

*/
#include "..\defines.h"

#define INF      "OIA_InfTeam","OI_reconPatrol","OIA_GuardTeam"
#define VEHMRAP  "O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F", "O_MRAP_02_F", "O_LSV_02_armed_F", "O_Truck_03_transport_F", "O_Truck_03_covered_F"
#define VEHRAND  "O_APC_Tracked_02_cannon_F", "O_APC_Wheeled_02_rcws_F"

params [
        "_missionID", "_center", "_radius",
        ["_garrisons", [1,0,60, "SME", 4, []]],
        ["_inf", [3,3]],
        ["_infaa", [1,1]],
        ["_infat", [1,1]],
        ["_sniper", [1,1]],
        ["_vehaa", [0,0]],
        ["_vehmrap", [1,0]],
        ["_vehrand", [0,0]]
       ];

_garrisons params ["_garrisonGroupCount", ["_garrisonMinRad", 0], ["_garrisonMaxRad", 60], ["_garrisonSkill", 2], ["_garrisonFill", 4], ["_garrisonExcludes", []]];
_inf params ["_infMin", "_infRand", ["_infSkill", 2]];
_infaa params ["_infaaMin", "_infaaRand", ["_infaaSkill", 2]];
_infat params ["_infatMin", "_infatRand", ["_infatSkill", 2]];
_sniper params ["_sniperMin", "_sniperRand", ["_sniperSkill", 2]];
_vehaa params ["_vehaaMin", "_vehaaRand", ["_vehaaSkill", 3]];
_vehmrap params ["_vehmrapMin", "_vehmrapRand", ["_vehmrapSkill", 3]];
_vehrand params ["_vehrandMin", "_vehrandRand", ["_vehrandSkill", 3]];


private ["_x","_g","_pos","_flatPos","_rpos","_v"];

// Simple protection for broken requests
if (_center isEqualTo [0,0]) exitWith {};

// Prep return values
private _groups = [];
private _vehicles = [];

///////////////////////////////////////////////////////////
// GARRISONS
///////////////////////////////////////////////////////////

private _garrisonedGroups = ([_center, [_garrisonMinRad, _garrisonMaxRad], _garrisonGroupCount, nil, _garrisonSkill, _garrisonFill, _garrisonExcludes] call FNC(infantryGarrison));
{ _groups pushBack _x; _x setGroupIdGlobal [format["%1_gar%2", _missionID, _forEachIndex]]; } forEach _garrisonedGroups;

///////////////////////////////////////////////////////////
// STANDARD INFANTRY
///////////////////////////////////////////////////////////

for "_x" from 1 to (_infMin + floor(random (_infRand+1))) do {
    _rpos = [[[_center, _radius],[]],["water","out"]] call BIS_fnc_randomPos;
    _g = [_rpos, EAST, (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> selectRandom [INF])] call BIS_fnc_spawnGroup;
    _g setGroupIdGlobal [format["%1_inf%2", _missionID, _x]];
    [_g, _center, _radius/1.5, 3 + round (random 2), "SAD", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBA_fnc_taskPatrol;
    [_g, _infSkill] call FNC(setUnitSkill);
    _groups pushBack _g;
};

///////////////////////////////////////////////////////////
// AA INFANTRY
///////////////////////////////////////////////////////////

for "_x" from 1 to (_infaaMin + floor(random (_infaaRand+1))) do {
    _rpos = [[[_center, _radius],[]],["water","out"]] call BIS_fnc_randomPos;
    _g = [_rpos, EAST, (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfTeam_AA")] call BIS_fnc_spawnGroup;
    _g setGroupIdGlobal [format["%1_infaa%2", _missionID, _x]];
    [_g, _center, _radius/1.5, 3 + round (random 2), "SAD", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBA_fnc_taskPatrol;
    [_g, _infaaSkill] call FNC(setUnitSkill);
    _groups pushBack _g;
};

///////////////////////////////////////////////////////////
// AT INFANTRY
///////////////////////////////////////////////////////////

for "_x" from 1 to (_infatMin + floor(random (_infatRand+1))) do {
    _rpos = [[[_center, _radius],[]],["water","out"]] call BIS_fnc_randomPos;
    _g = [_rpos, EAST, (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OIA_InfTeam_AA")] call BIS_fnc_spawnGroup;
    _g setGroupIdGlobal [format["%1_infat%2", _missionID, _x]];
    [_g, _center, _radius/1.5, 3 + round (random 2), "SAD", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBA_fnc_taskPatrol;
    [_g, _infatSkill] call FNC(setUnitSkill);
    _groups pushBack _g;
};

///////////////////////////////////////////////////////////
// SNIPER TEAMS
///////////////////////////////////////////////////////////
for "_x" from 1 to (_sniperMin + floor(random (_sniperRand+1))) do {
    _rpos = [_center, _radius, 100, 20] call BIS_fnc_findOverwatch;
    _g = [_rpos, east, (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> "OI_SniperTeam")] call BIS_fnc_spawnGroup;
    _g setGroupIdGlobal [format["%1_sniper%2", _missionID, _x]];
    _g setBehaviour "COMBAT";
    _g setCombatMode "RED";
    [_g, _sniperSkill] call FNC(setUnitSkill);
    _groups pushBack _g;
};

///////////////////////////////////////////////////////////
// TIGRIS
///////////////////////////////////////////////////////////

for "_x" from 1 to (_vehaaMin + floor(random (_vehaaRand+1))) do {

    _g = createGroup east;
    _g setGroupIdGlobal [format ["%1_VehAA%2", _missionID, _x]];

    _rpos = [[[_center, _radius], []], ["water", "out"], { !(_this isFlatEmpty [2,-1,0.5,1,0,false,objNull] isEqualTo []) }] call BIS_fnc_randomPos;

    if !(_rpos isEqualTo [0,0]) then {
        _v = "O_APC_Tracked_02_vehaa_F" createVehicle _rpos ;
        _v lock 2;

        [_v, _g] call BIS_fnc_spawnCrew;
        [_g, _center, _radius / 2, 3 + round (random 2), "SAD", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBA_fnc_taskPatrol;
        [_g, _vehaaSkill] call FNC(setUnitSkill);
        if (random 1 >= 0.5) then { _v allowCrewInImmobile true; };

        _groups pushBack _g;
        _vehicles pushBack _v;
    };
};

///////////////////////////////////////////////////////////
// MRAP
///////////////////////////////////////////////////////////

for "_x" from 1 to (_vehmrapMin + floor(random (_vehmrapRand+1))) do {

    _g = createGroup east;
    _g setGroupIdGlobal [format ["%1_vehmrap%2", _missionID, _x]];

    _rpos = [[[_center, _radius], []], ["water", "out"], { !(_this isFlatEmpty [2,-1,0.5,1,0,false,objNull] isEqualTo []) }] call BIS_fnc_randomPos;

    if !(_rpos isEqualTo [0,0]) then {
        _v = (selectRandom [VEHMRAP]) createVehicle _rpos ;
        _v lock 3;

        [_v, _g] call BIS_fnc_spawnCrew;
        [_g, _center, _radius / 2, 3 + round (random 2), "SAD", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBA_fnc_taskPatrol;
        [_g, _vehmrapSkill] call FNC(setUnitSkill);
        if (random 1 >= 0.5) then { _v allowCrewInImmobile true; };

        _groups pushBack _g;
        _vehicles pushBack _v;
    };
};

///////////////////////////////////////////////////////////
// RANDOM VEHS
///////////////////////////////////////////////////////////

for "_x" from 1 to (_vehrandMin + floor(random (_vehrandRand+1))) do {

    _g = createGroup east;
    _g setGroupIdGlobal [format ["%1_vehrand%2", _missionID, _x]];

    _rpos = [[[_center, _radius], []], ["water", "out"], { !(_this isFlatEmpty [2,-1,0.5,1,0,false,objNull] isEqualTo []) }] call BIS_fnc_randomPos;

    if !(_rpos isEqualTo [0,0]) then {
        _v = (selectRandom [VEHRAND]) createVehicle _rpos ;
        _v lock 3;

        [_v, _g] call BIS_fnc_spawnCrew;
        [_g, _center, _radius / 2, 3 + round (random 2), "SAD", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBA_fnc_taskPatrol;
        [_g, _vehrandSkill] call FNC(setUnitSkill);
        if (random 1 >= 0.5) then { _v allowCrewInImmobile true; };

        _groups pushBack _g;
        _vehicles pushBack _v;
    };
};

[_groups, _vehicles]