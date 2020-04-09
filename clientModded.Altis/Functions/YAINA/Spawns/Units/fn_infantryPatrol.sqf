/*
Function: YAINA_SPAWNS_fnc_infantryPatrol

Description:
	Create an infantry patrol of given side with passed skill level
    at given position patrolling in given radius.

Parameters:
	_pos - The position at which to place the patrol
    _patrolRadius - The radius in which to patrol
    _skill - The skill level of the patrolling units
    _side - The side of the units we want to create

Return Values:
	The patrol group newly created

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_pos", ["_patrolRadius", 0], ["_skill", "LRG Default"], ["_side", EAST]];

private _groupTypes = [];
private _faction    = "";
private _cside      = "";

_groupTypes = call {
    if(_side isEqualTo East) exitWith { _cside = "East"; _faction = "OPF_F"; ["OIA_InfSquad", "OIA_InfSquad_Weapons", "OIA_InfAssault", "OIA_ReconSquad"] };
    if(_side isEqualTo independent) exitWith { _cside = "Indep" ; _faction = "IND_C_F"; ["BanditCombatGroup", "BanditShockTeam", "BanditFireTeam"] };
    []
};

if (_groupTypes isEqualTo []) exitWith { objNull };

// pos is a guideline, so lets find a safe pos...
private _safepos = [_pos,0,27,1,0,2000,0] call BIS_fnc_findSafePos;
private _g = [_safepos, _side, (configFile >> "CfgGroups" >> _cside >> _faction >> "Infantry" >> (selectRandom _groupTypes))] call BIS_fnc_spawnGroup;

[_g, _skill] call FNC(setUnitSkill);

if (_patrolRadius > 0) then {
    [_g, _pos, _patrolRadius, (ceil(random 4) + 3), "sad", ["AWARE", "SAFE"] select (random 1 > 0.5), "red", "limited"] call CBA_fnc_taskPatrol;
};

// Units
_u = units _g;

// Add units to zeus
[_u] call YFNC(addEditableObjects);

// return the group
_u;