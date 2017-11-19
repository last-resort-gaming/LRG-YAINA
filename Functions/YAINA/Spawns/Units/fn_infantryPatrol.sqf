/*
	author: Martin
	description: none
	returns: nothing
*/
#include "..\defines.h"

params ["_pos", ["_patrolRadius", 0], ["_skill", 2]];

private _groupTypes = [
    "OIA_InfSquad",
    "OIA_InfSquad_Weapons",
    "OIA_InfAssault",
    "OIA_ReconSquad"
];

// pos is a guideline, so lets find a safe pos...
private _safepos = [_pos,0,27,1,0,2000,0] call BIS_fnc_findSafePos;
private _g = [_safepos, EAST, (configFile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> (selectRandom _groupTypes))] call BIS_fnc_spawnGroup;

[_g, _skill] call FNC(setUnitSkill);

if (_patrolRadius > 0) then {
    [_g, _pos, _patrolRadius] call BIS_fnc_taskPatrol;
};

// 50% of AWARE / SAFE
_g setBehaviour (["AWARE", "SAFE"] select (random 1 > 0.5));

// Aggressive ? 10% chance of being fire at will, engage at will
_g setCombatMode (["RED", "WHITE"] select (random 1 > 0.1));

// Add units to zeus
[units _g] call YFNC(addEditableObjects);

// return the group
_g;