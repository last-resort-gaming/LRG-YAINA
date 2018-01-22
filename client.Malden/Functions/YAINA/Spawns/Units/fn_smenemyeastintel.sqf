/*
@filename: QS_fnc_SMenemyEASTintel.sqf
Author: 

	Quiksilver
	
Last modified:

	25/04/2014

Description:

	Spawn OPFOR enemy around intel objectives
	Enemy should have backbone AA/AT + random composition.
	Smaller number of enemy due to more complex objective.
	
___________________________________________*/

//---------- CONFIG

#define INF_TEAMS "OIA_InfTeam","OIA_InfTeam_AT","OIA_InfTeam_AA","OI_reconPatrol","OIA_GuardTeam"
#define VEH_TYPES "O_MRAP_02_gmg_F","O_MRAP_02_hmg_F","O_APC_Tracked_02_cannon_F"
#include "..\defines.h"

params  ["_intelObj"];
private ["_x","_pos","_flatPos","_randomPos","_unitsArray","_enemiesArray","_infteamPatrol","_SMvehPatrol","_SMveh","_SMaaPatrol","_SMaa"];

private _intelPos = getPos _intelObj;
private _groups = [];
private _vehs   = [];

//---------- INFANTRY

for "_x" from 0 to (1 + (random 3)) do {

	_randomPos = [[[_intelPos, 300],[]],["water","out"]] call BIS_fnc_randomPos;

	_infteamPatrol = [_randomPos, EAST, (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> [INF_TEAMS] call BIS_fnc_selectRandom)] call BIS_fnc_spawnGroup;
	_groups pushBack _infteamPatrol;

	[_infteamPatrol, _intelPos, 100] call BIS_fnc_taskPatrol;
	[_infteamPatrol, 2] call FNC(setUnitSkill);

};

//---------- RANDOM VEHICLE

_SMvehPatrol = createGroup east;
_groups pushBack _SMvehPatrol;


_randomPos = [[[_intelPos, 300],[]],["water","out"]] call BIS_fnc_randomPos;

_SMveh = [VEH_TYPES] call BIS_fnc_selectRandom createVehicle _randomPos;
_vehs pushBack _SMveh;
_SMveh lock 3;

[_SMveh, _SMvehPatrol] call BIS_fnc_spawnCrew;
[_SMvehPatrol, _intelPos, 150] call BIS_fnc_taskPatrol;
[_SMvehPatrol, 2] call FNC(setUnitSkill);

if (random 1 >= 0.5) then {
	_SMveh allowCrewInImmobile true;
};
	
[_groups, _vehs]