/*
Function: YAINA_SPAWNS_fnc_populateArea

Description:
	Populate the given area, mainly used for populating AOs.
    Has lots of available options to adjust the population routine.

Parameters:
	_grpPrefix - The prefix for the group IDs
    _center - The center position of the area we want to populate
    _radius - The radius of the area we want to populate
    _side - The side of the units we want to create
    _army - The faction which we want to use for populating the AO
    _garrisons - Garrison Parameters, array containing the following information: [Group Count, Minimum Radius, Maximum Radius, Skill Level of Garrisoned Units, Maximum Fill in Buildling, Exclusion List]
    _inf - Infantry Parameters, array containing the following information: [Minimum Amount of Groups, Random Upper Bound of Groups, Skill Level of the units]
    _infaa - AA Parameters, array containing the following information: [Minimum Amount of Groups, Random Upper Bound of Groups, Skill Level of the units]
    _infat - AT Parameters, array containing the following information: [Minimum Amount of Groups, Random Upper Bound of Groups, Skill Level of the units]
    _sniper - Sniper Parameters, array containing the following information: [Minimum Amount of Groups, Random Upper Bound of Groups, Skill Level of the units]
    _vehaa - Vehicle-based AA Parameters, array containing the following information: [Minimum Amount of Groups, Random Upper Bound of Groups, Skill Level of the units]
    _vehmrap - MRAP Parameters, array containing the following information: [Minimum Amount of Groups, Random Upper Bound of Groups, Skill Level of the units]
    _vehran - Random Vehicles Parameters, array containing the following information: [Minimum Amount of Groups, Random Upper Bound of Groups, Skill Level of the units]
    _vehlight - Light Vehicles Parameters, array containing the following information: [Minimum Amount of Groups, Random Upper Bound of Groups, Skill Level of the units]
    _vehheavy - Heavy/Armoured Vehicle Parameters, array containing the following information: [Minimum Amount of Groups, Random Upper Bound of Groups, Skill Level of the units]

Return Values:
	Array containing the following information:

    _units - The newly created AO population (i.e. the spawned units)
    _vehicles - The newly spawned vehicles in the AO

Examples:
    Nothing to see here

Author:
	Martin - Original Function
    MitchJC - Faction Selection
*/

#include "..\defines.h"

params [
	"_grpPrefix", "_center", "_radius",
	["_army", "CSAT"],
	["_garrisons", [1,0,60, "LRG Default", 4, []]],
	["_inf", [3,3]],
	["_infaa", [0,0]],
	["_infat", [0,0]],
	["_sniper", [0,0]],
	["_vehaa", [0,0]],
	["_vehmrap", [0,0]],
	["_vehrand", [0,0]],
	["_vehlight", [0,0]],
	["_vehheavy", [0,0]]
];

_typeNameCenter = typeName _center;

call {
	if (_typeNameCenter isEqualTo "OBJECT") exitwith { _center = getPos _center;};
	if (_typeNameCenter isEqualTo "STRING") exitwith { _center = getMarkerPos _center;};
	if (_typeNameCenter isEqualTo [0, 0, 0]) exitwith {systemchat "AISpawns - Position is invalid";};

};

_center set [2, 0];

_garrisons params ["_garrisonGroupCount", ["_garrisonMinRad", 0], ["_garrisonMaxRad", 60], ["_garrisonSkill", 2], ["_garrisonFill", 4], ["_garrisonExcludes", []]];
_inf params ["_infMin", ["_infRand", 0], ["_infSkill", "LRG Default"]];
_infaa params ["_infaaMin", ["_infaaRand",0], ["_infaaSkill", "LRG Default"]];
_infat params ["_infatMin", ["_infatRand",0], ["_infatSkill", "LRG Default"]];
_sniper params ["_sniperMin", ["_sniperRand",0], ["_sniperSkill", "LRG Default"]];
_vehaa params ["_vehaaMin", ["_vehaaRand",0], ["_vehaaSkill", "LRG Default"]];
_vehmrap params ["_vehmrapMin", ["_vehmrapRand",0], ["_vehmrapSkill", "LRG Default"]];
_vehrand params ["_vehrandMin", ["_vehrandRand",0], ["_vehrandSkill", "LRG Default"]];
_vehlight params ["_vehlightMin", ["_vehlightRand",0], ["_vehlightSkill", "LRG Default"]];
_vehheavy params ["_vehheavyMin", ["_vehheavyRand",0], ["_vehheavySkill", "LRG Default"]];

///////////////////////////////////////////////////////////
// UNIT TYPES
///////////////////////////////////////////////////////////

private ["_side", "_infList", "_confBase", "_infaaList", "_infatList", "_sniperList", "_vehAAList", "_vehMrapList", "_vehRandList", "_vehLightList", "_vehHeavyList"];

// TODO: UAVs ?

call {
	
	_side = east;
	
	if (_army isEqualto "CSAT") exitwith {
		_confBase     = configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry";
		_infList      = ["OIA_InfTeam","OI_reconPatrol"];
		_infaaList    = ["OIA_InfTeam_AA"];
		_infatList    = ["OIA_InfTeam_AT"];
		_sniperList   = ["OI_SniperTeam"];
		_vehAAList    = ["O_APC_Tracked_02_AA_F"];
		_vehMrapList  = ["O_MRAP_02_F", "O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F", "O_LSV_02_armed_F", "O_Truck_03_transport_F", "O_Truck_03_covered_F"];
		_vehRandList  = ["O_APC_Tracked_02_cannon_F", "O_APC_Wheeled_02_rcws_F"];
		_vehLightList = ["O_LSV_02_armed_F", "O_G_Offroad_01_armed_F"];
		_vehHeavyList = ["O_MBT_02_cannon_F", "O_MBT_04_cannon_F", "O_MBT_04_command_F"];
		};
    case "AAF": {
		_side = resistance;
		_confBase = configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry";
		_infList      = ("true" configClasses _confBase) apply { configName _x };
		_infaaList    = ["HAF_InfTeam_AA"];
		_infatList    = ["HAF_InfTeam_AT"];
		_sniperList   = ["HAF_SniperTeam"];
		_vehAAList    = ["I_APC_Wheeled_03_cannon_F", "I_LT_01_AA_F"];
		_vehMrapList  = ["I_MRAP_03_F", "I_MRAP_03_gmg_F", "I_MRAP_03_hmg_F", "I_Truck_02_transport_F", "I_Truck_02_transport_F"];
		_vehRandList  = ["I_APC_Tracked_C03_cannon_F"];
		_vehLightList = ["I_G_Offroad_01_armed_F"];
		_vehHeavyList = ["I_MBT_03_cannon_F", "I_LT_01_AT_F", "I_LT_01_cannon_F"];
		};
    case "CSAT Pacific": {
		_side = east;
		_confBase = configfile >> "CfgGroups" >> "East" >> "OPF_T_F" >> "Infantry";
		_infList      = ("true" configClasses _confBase) apply { configName _x };
		_infaaList    = ["O_T_InfTeam_AA"];
		_infatList    = ["O_T_InfTeam_AT","O_T_InfTeam_AT_Heavy"];
		_sniperList   = ["O_T_SniperTeam"];
		_vehAAList    = ["O_T_APC_Tracked_02_AA_ghex_F"];
		_vehMrapList  = ["O_T_MRAP_02_ghex_F","O_T_MRAP_02_gmg_ghex_F","O_T_MRAP_02_hmg_ghex_F","O_T_LSV_02_AT_F","O_T_LSV_02_armed_F","O_T_LSV_02_unarmed_F"];
		_vehRandList  = ["O_T_APC_Tracked_02_cannon_ghex_F","O_T_APC_Wheeled_02_rcws_v2_ghex_F"];
		_vehLightList = ["O_T_LSV_02_armed_F","O_T_LSV_02_unarmed_F"];
		_vehHeavyList = ["O_T_MBT_02_cannon_ghex_F","O_T_MBT_04_cannon_F","O_T_MBT_04_command_F"];
		};
    case "Syndikat": {
		_side = resistance;
		_confBase = configfile >> "CfgGroups" >> "Indep" >> "IND_C_F" >> "Infantry";
		_infList      = ("true" configClasses _confBase) apply { configName _x };
		_infaaList    = [];
		_infatList    = [];
		_sniperList   = [];
		_vehAAList    = ["I_APC_Wheeled_03_cannon_F"];
		_vehMrapList  = ["I_MRAP_03_F", "I_MRAP_03_gmg_F", "I_MRAP_03_hmg_F", "I_Truck_02_transport_F", "I_Truck_02_transport_F"];
		_vehRandList  = ["I_APC_Tracked_C03_cannon_F"];
		_vehLightList = ["I_G_Offroad_01_armed_F"];
		_vehHeavyList = ["I_MBT_03_cannon_F", "I_LT_01_AT_F", "I_LT_01_cannon_F"];
		};
    default {
		_side = east;
		_confBase     = configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry";
		_infList      = ["OIA_InfTeam","OI_reconPatrol"];
		_infaaList    = ["OIA_InfTeam_AA"];
		_infatList    = ["OIA_InfTeam_AT"];
		_sniperList   = ["OI_SniperTeam"];
		_vehAAList    = ["O_APC_Tracked_02_AA_F"];
		_vehMrapList  = ["O_MRAP_02_F", "O_MRAP_02_hmg_F", "O_MRAP_02_gmg_F", "O_LSV_02_armed_F", "O_Truck_03_transport_F", "O_Truck_03_covered_F"];
		_vehRandList  = ["O_APC_Tracked_02_cannon_F", "O_APC_Wheeled_02_rcws_F"];
		_vehLightList = ["O_LSV_02_armed_F", "O_G_Offroad_01_armed_F"];
		_vehHeavyList = ["O_MBT_02_cannon_F", "O_MBT_04_cannon_F", "O_MBT_04_command_F"];
		};
};

private ["_x","_g","_pos","_flatPos","_rpos","_v"];

// Simple protection for broken requests
if (_center isEqualTo [0,0]) exitWith {};

// Prep return values
private _units = [];
private _vehicles = [];

///////////////////////////////////////////////////////////
// GARRISONS
///////////////////////////////////////////////////////////

if (_garrisonGroupCount > 0) then {
    private _garrisonedUnits = ([_center, [_garrisonMinRad, _garrisonMaxRad], _army, _garrisonGroupCount, nil, _garrisonSkill, _garrisonFill, _garrisonExcludes] call FNC(infantryGarrison));
    _units append _garrisonedUnits;

    private _grps = [];
    { _grps pushBackUnique (group _x); nil } count _units;

    // tag groups
    { _x setGroupIdGlobal [format["%1_gar%2", _grpPrefix, _forEachIndex]]; } forEach _grps;
};

///////////////////////////////////////////////////////////
// STANDARD INFANTRY
///////////////////////////////////////////////////////////
if !(_infList isEqualTo []) then {
    for "_x" from 1 to (_infMin + floor(random (_infRand+1))) do {
        _rpos = [[[_center, _radius],[]],["water","out"]] call BIS_fnc_randomPos;
        _g = [_rpos, _side, _confBase >> (selectRandom _infList)] call BIS_fnc_spawnGroup;
        _g setGroupIdGlobal [format["%1_inf%2", _grpPrefix, _x]];
        [_g, _center, _radius/1.5, 3 + round (random 2), ["SAD", "MOVE"] select (random 1 > 0.33), ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBAP_fnc_taskPatrol;
        [_g, _infSkill] call FNC(setUnitSkill);
        _units append (units _g);
    };
};

///////////////////////////////////////////////////////////
// AA INFANTRY
///////////////////////////////////////////////////////////

if !(_infaaList isEqualTo []) then {
    for "_x" from 1 to (_infaaMin + floor(random (_infaaRand+1))) do {
        _rpos = [[[_center, _radius],[]],["water","out"]] call BIS_fnc_randomPos;
        _g = [_rpos, _side, _confBase >> (selectRandom _infaaList)] call BIS_fnc_spawnGroup;
        _g setGroupIdGlobal [format["%1_infaa%2", _grpPrefix, _x]];
        [_g, _center, _radius/1.5, 3 + round (random 2), "SAD", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBAP_fnc_taskPatrol;
        [_g, _infaaSkill] call FNC(setUnitSkill);
        _units append (units _g);
    };
};

///////////////////////////////////////////////////////////
// AT INFANTRY
///////////////////////////////////////////////////////////

if !(_infatList isEqualTo []) then {
    for "_x" from 1 to (_infatMin + floor(random (_infatRand+1))) do {
        _rpos = [[[_center, _radius],[]],["water","out"]] call BIS_fnc_randomPos;
        _g = [_rpos, _side, _confBase >> (selectRandom _infatList)] call BIS_fnc_spawnGroup;
        _g setGroupIdGlobal [format["%1_infat%2", _grpPrefix, _x]];
        [_g, _center, _radius/1.5, 3 + round (random 2), "SAD", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBAP_fnc_taskPatrol;
        [_g, _infatSkill] call FNC(setUnitSkill);
        _units append (units _g);
    };
};

///////////////////////////////////////////////////////////
// SNIPER TEAMS
///////////////////////////////////////////////////////////
if !(_sniperList isEqualTo []) then {
    for "_x" from 1 to (_sniperMin + floor(random (_sniperRand+1))) do {
        _rpos = [_center, _radius, 100, 20] call BIS_fnc_findOverwatch;
        _g = [_rpos, _side, _confBase >> (selectRandom _sniperList)] call BIS_fnc_spawnGroup;
        _g setGroupIdGlobal [format["%1_sniper%2", _grpPrefix, _x]];
        _g setBehaviour "COMBAT";
        _g setCombatMode "RED";
        [_g, _sniperSkill] call FNC(setUnitSkill);
        _units append (units _g);
    };
};

///////////////////////////////////////////////////////////
// AA
///////////////////////////////////////////////////////////

if !(_vehAAList isEqualTo []) then {
    for "_x" from 1 to (_vehaaMin + floor(random (_vehaaRand+1))) do {

        _g = createGroup _side;
        _g setGroupIdGlobal [format ["%1_VehAA%2", _grpPrefix, _x]];

        _rpos = [[[_center, _radius], []], ["water", "out"], { !(_this isFlatEmpty [2,-1,0.5,1,0,false,objNull] isEqualTo []) }] call BIS_fnc_randomPos;

        if !(_rpos isEqualTo [0,0]) then {
            _v = (selectRandom _vehAAList) createVehicle _rpos ;
            _v lock 2;

            [_v, _g] call BIS_fnc_spawnCrew;
            [_g, _center, _radius / 2, 3 + round (random 2), "MOVE", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBAP_fnc_taskPatrol;
            [_g, _vehaaSkill] call FNC(setUnitSkill);
            if (random 1 >= 0.5) then { _v allowCrewInImmobile true; };

            _units append (units _g);
            _vehicles pushBack _v;
        };
    };
};

///////////////////////////////////////////////////////////
// MRAP
///////////////////////////////////////////////////////////

if !(_vehmrapList isEqualTo []) then {
    for "_x" from 1 to (_vehmrapMin + floor(random (_vehmrapRand+1))) do {

        _g = createGroup _side;
        _g setGroupIdGlobal [format ["%1_vehmrap%2", _grpPrefix, _x]];

        _rpos = [[[_center, _radius], []], ["water", "out"], { !(_this isFlatEmpty [2,-1,0.5,1,0,false,objNull] isEqualTo []) }] call BIS_fnc_randomPos;

        if !(_rpos isEqualTo [0,0]) then {
            _v = (selectRandom _vehmrapList) createVehicle _rpos ;
            _v lock 3;

            [_v, _g] call BIS_fnc_spawnCrew;
            [_g, _center, _radius / 2, 3 + round (random 2), "MOVE", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBAP_fnc_taskPatrol;
            [_g, _vehmrapSkill] call FNC(setUnitSkill);
            if (random 1 >= 0.5) then { _v allowCrewInImmobile true; };

            _units append (units _g);
            _vehicles pushBack _v;
        };
    };
};

///////////////////////////////////////////////////////////
// RANDOM VEHS
///////////////////////////////////////////////////////////

if (_vehRandList isEqualTo []) then {
    for "_x" from 1 to (_vehrandMin + floor(random (_vehrandRand+1))) do {

        _g = createGroup _side;
        _g setGroupIdGlobal [format ["%1_vehrand%2", _grpPrefix, _x]];

        _rpos = [[[_center, _radius], []], ["water", "out"], { !(_this isFlatEmpty [2,-1,0.5,1,0,false,objNull] isEqualTo []) }] call BIS_fnc_randomPos;

        if !(_rpos isEqualTo [0,0]) then {
            _v = (selectRandom _vehRandList) createVehicle _rpos ;
            _v lock 3;

            [_v, _g] call BIS_fnc_spawnCrew;
            [_g, _center, _radius / 2, 3 + round (random 2), "MOVE", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBAP_fnc_taskPatrol;
            [_g, _vehrandSkill] call FNC(setUnitSkill);
            if (random 1 >= 0.5) then { _v allowCrewInImmobile true; };

            _units append (units _g);
            _vehicles pushBack _v;
        };
    };
};

///////////////////////////////////////////////////////////
// LIGHT VEHS
///////////////////////////////////////////////////////////

if (_vehLightList isEqualTo []) then {
    for "_x" from 1 to (_vehLightMin + floor(random (_vehLightRand+1))) do {

        _g = createGroup _side;
        _g setGroupIdGlobal [format ["%1_vehLight%2", _grpPrefix, _x]];

        _rpos = [[[_center, _radius], []], ["water", "out"], { !(_this isFlatEmpty [2,-1,0.5,1,0,false,objNull] isEqualTo []) }] call BIS_fnc_randomPos;

        if !(_rpos isEqualTo [0,0]) then {
            _v = (selectRandom _vehLightList) createVehicle _rpos ;
            _v lock 3;

            [_v, _g] call BIS_fnc_spawnCrew;
            [_g, _center, _radius / 2, 3 + round (random 2), "MOVE", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBAP_fnc_taskPatrol;
            [_g, _vehLightSkill] call FNC(setUnitSkill);
            if (random 1 >= 0.5) then { _v allowCrewInImmobile true; };

            _units append (units _g);
            _vehicles pushBack _v;
        };
    };
};

///////////////////////////////////////////////////////////
// RANDOM VEHS
///////////////////////////////////////////////////////////

if (_vehHeavyList isEqualTo []) then {
    for "_x" from 1 to (_vehHeavyMin + floor(random (_vehHeavyRand+1))) do {

        _g = createGroup _side;
        _g setGroupIdGlobal [format ["%1_vehHeavy%2", _grpPrefix, _x]];

        _rpos = [[[_center, _radius], []], ["water", "out"], { !(_this isFlatEmpty [2,-1,0.5,1,0,false,objNull] isEqualTo []) }] call BIS_fnc_randomPos;

        if !(_rpos isEqualTo [0,0]) then {
            _v = (selectRandom _vehHeavyList) createVehicle _rpos ;
            _v lock 3;

            [_v, _g] call BIS_fnc_spawnCrew;
            [_g, _center, _radius / 2, 3 + round (random 2), "MOVE", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBAP_fnc_taskPatrol;
            [_g, _vehHeavySkill] call FNC(setUnitSkill);
            if (random 1 >= 0.5) then { _v allowCrewInImmobile true; };

            _units append (units _g);
            _vehicles pushBack _v;
        };
    };
};

{
	if !(dynamicSimulationEnabled (group _x)) then {
		(group _x) enableDynamicSimulation true;
	};
	_x 	disableAI "AUTOCOMBAT";
} forEach _units;

{
	if !(dynamicSimulationEnabled (group _x)) then {
		(group _x) enableDynamicSimulation true;
	};
} forEach _vehicles;

[_units, _vehicles]
