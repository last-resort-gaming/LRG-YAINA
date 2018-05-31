/*
	author: Martin
	MitchJC - Faction Switching
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_pos", ["_radius", [0, 30]], "_army", ["_groupCount", 1], ["_AIOB_Positioning", 2], ["_skill", 2], ["_maxFill", 4], ["_excludes", []], ["_units", []]];

if (_units isEqualTo []) then {

private ["_groupType", "_side"];

switch (_army) do {
    case "CSAT": {
		_side = east;
		_groupType = (configFile >> "CfgGroups" >> "East" >> "OPF_F" >> "UInfantry" >> "OIA_GuardSquad");
		};
    case "CSAT Pacific": {
		_side = east;
		_groupType = (configfile >> "CfgGroups" >> "East" >> "OPF_T_F" >> "Infantry" >> "O_T_InfSquad");
		};
    case "AAF": {
		_side = resistance;
		_groupType = (configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry" >> "HAF_InfSquad");
		};
    case "Syndikat": {
		_side = resistance;
		_groupType = (configfile >> "CfgGroups" >> "Indep" >> "IND_C_F" >> "Infantry" >> "BanditCombatGroup");
		};
    default {
		_side = east;
		_groupType = (configFile >> "CfgGroups" >> "East" >> "OPF_F" >> "UInfantry" >> "OIA_GuardSquad");
		};
};

		
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
