/*
Function: YAINA_SPAWNS_fnc_infantryGarrison

Description:
	Garrison buildings in given radius around given position, using
	units of the passed faction.

Parameters:
	_pos - Position around which to garrison buildings
	_radius - Radius around the position in which to garrison buildings
	_army - The faction which we want to use to populate the garrisons
	_groupCount - The amount of groups we want to create
	_AIOB_Positioning - The positioning directive to use (default: 2)
	_skill - The skill level of the garrisoned units
	_maxFill - The maximum amount of units in one building
	_excludes - Exclude buildings in this array from being garrisoned
	_units - Array of units already in existence which we want to garrison as well


Return Values:
	Array containing the garrisoned units

Examples:
    Nothing to see here

Author:
	Martin - Original Function
	MitchJC - Faction Selection
*/

#include "..\defines.h"

params ["_pos", ["_radius", [0, 30]], "_army", ["_groupCount", 1], ["_AIOB_Positioning", 2], ["_skill", "LRG Default"], ["_maxFill", 4], ["_excludes", []], ["_units", []]];

if (_units isEqualTo []) then {

private ["_groupType", "_side"];

	_army call {

		_side = east;

		if (_this isEqualto "CSAT") exitWith {
			_groupType = (configFile >> "CfgGroups" >> "East" >> "OPF_F" >> "UInfantry" >> "OIA_GuardSquad");
			[_groupType, _side];
		};

		if (_this isEqualto "CSAT Pacific") exitWith {
			_groupType = (configFile >> "CfgGroups" >> "East" >> "OPF_T_F" >> "Infantry" >> "O_T_InfSquad");
			[_groupType, _side];
		};

		if (_this isEqualto "AAF") exitWith {
			_side = resistance;
			_groupType = (configFile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry" >> "HAF_InfSquad");
			[_groupType, _side];
		};

		if (_this isEqualto "Syndikat") exitWith {
			_side = resistance;
			_groupType = (configFile >> "CfgGroups" >> "Indep" >> "IND_C_F" >> "Infantry" >> "BanditCombatGroup");
			[_groupType, _side];
		};

		if (_this isEqualto "TM") exitWith {
			_groupType = (configFile >> "CfgGroups" >> "East" >> "CUP_O_TK_MILITIA" >> "Infantry" >> "CUP_O_TK_MILITIA_Group");
			[_groupType, _side];
		};

		if (_this isEqualto "CRS") exitWith {
			_groupType = (configFile >> "CfgGroups" >> "East" >> "CUP_O_ChDKZ" >> "Infantry" >> "CUP_O_ChDKZ_InfSquad");
			[_groupType, _side];
		};

		if (_this isEqualto "CUP AFRF") exitWith {
			_groupType = (configFile >> "CfgGroups" >> "East" >> "CUP_O_RU" >> "Infantry" >> "CUP_O_RU_InfSquad_EMR");
			[_groupType, _side];
		};

		if (_this isEqualto "SLA") exitWith {
			_groupType = (configFile >> "CfgGroups" >> "East" >> "CUP_O_SLA" >> "Infantry_Urban" >> "CUP_O_SLA_InfantrySquad_Urban");
			[_groupType, _side];
		};

		if (_this isEqualto "TA") exitWith {
			_groupType = (configFile >> "CfgGroups" >> "East" >> "CUP_O_TK" >> "Infantry" >> "CUP_O_TK_InfantrySquad");
			[_groupType, _side];
		};
	} params ["_groupType", "_side"];

    for "_x" from 1 to _groupCount do {
        private _g = [_pos, _side, _groupType] call BIS_fnc_spawnGroup;
        _units append (units _g);
    };
};

if (_units isEqualTo []) exitWith { [] };

private _failed = [_pos, nil, _units, _radius, _AIOB_Positioning, true, _maxFill, _excludes] call DERP_fnc_AIOccupyBuilding;

// Remove any non-garrisoned units
{ deleteVehicle _x; } forEach _failed;
_allUnits = _units - _failed;

// Set Skill
[_allUnits, _skill] call FNC(setUnitSkill);

// Add units to zeus
[_allUnits] call YFNC(addEditableObjects);

_allUnits;
