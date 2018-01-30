/*
    Author: alganthe
    Handles creating the AI
    Modified by: BACONMOP
    Modified for Sidemission AI
    Ported to YAINA
*/

#include "..\defines.h"

params ["_smPos","_radiusSize","_AAAVehcAmount","_MRAPAmount","_randomVehcsAmount","_infantryGroupsAmount","_AAGroupsAmount","_ATGroupsAmount"];

private _spawnedGroups = [];
private _spawnedVehicles = [];
private ["_grp1"];

//-------------------------------------------------- AA vehicles
for "_x" from 1 to _AAAVehcAmount do {
    private _randomPos = [[[_smPos, (_radiusSize / 1.5)], []], ["water", "out"]] call BIS_fnc_randomPos;

    private _AAVehicle = (selectRandom ["I_G_Offroad_01_armed_F", "I_APC_Wheeled_03_cannon_F"]) createVehicle _randomPos;

    _AAVehicle allowCrewInImmobile true;

    _AAVehicle lock 2;
    _grp1 = createGroup Resistance;
    _spawnedGroups pushBack _grp1;

    [_AAVehicle,_grp1,"AAF"] call FNC(createCrew);
    _spawnedVehicles pushBack _AAVehicle;

    [_grp1, _smPos, _radiusSize / 2] call BIS_fnc_taskPatrol;
    _grp1 setSpeedMode "LIMITED";
};

//-------------------------------------------------- MRAP
for "_x" from 1 to _MRAPAmount do {

    private _randomPos = [[[_smPos, _radiusSize], []], ["water", "out"]] call BIS_fnc_randomPos;
    private _MRAP = (selectRandom ["I_C_Offroad_02_unarmed_F","I_G_Offroad_01_armed_F","I_G_Offroad_01_F","I_G_Offroad_01_repair_F","I_MRAP_03_gmg_F","I_MRAP_03_F","I_MRAP_03_hmg_F","I_Truck_02_transport_F","I_Truck_02_covered_F"]) createVehicle _randompos;

    _MRAP allowCrewInImmobile true;
    _MRAP lock 2;
    _spawnedVehicles pushBack _MRAP;

    _grp1 = createGroup Resistance;
    [_MRAP,_grp1,"AAF"] call FNC(createCrew);
    _spawnedGroups pushBack _grp1;

    [_grp1, _smPos, _radiusSize / 3] call BIS_fnc_taskPatrol;
    _grp1 setSpeedMode "LIMITED";
};

//-------------------------------------------------- random vehcs
private ["_grp1"];
for "_x" from 1 to _randomVehcsAmount do {

    private _randomPos = [[[_smPos, _radiusSize], []], ["water", "out"]] call BIS_fnc_randomPos;
    private _vehc = (selectRandom ["I_APC_Wheeled_03_cannon_F","I_APC_tracked_03_cannon_F"]) createVehicle _randompos;

    _vehc allowCrewInImmobile true;
    _vehc lock 2;
    _spawnedVehicles pushBack _vehc;

    _grp1 = createGroup Resistance;
    [_vehc,_grp1,"AAF"] call FNC(createCrew);
    _spawnedGroups pushBack _grp1;

    [_grp1, _smPos, _radiusSize / 2] call BIS_fnc_taskPatrol;
    _grp1 setSpeedMode "LIMITED";
};

//-------------------------------------------------- main infantry groups

for "_x" from 1 to _infantryGroupsAmount do {

    private _randomPos = [[[_smPos, _radiusSize * 1.2], []], ["water", "out"]] call BIS_fnc_randomPos;
	private _infantryGroup = createGroup EAST;
	_spawnedGroups pushBack _infantryGroup;

	for "_x" from 1 to 8 do {
		_unit = ["I_Soldier_A_F","I_Soldier_AAR_F","I_Soldier_AAA_F","I_Soldier_AAT_F","I_Soldier_AR_F","I_medic_F","I_engineer_F","I_Soldier_exp_F","I_Soldier_GL_F","I_Soldier_M_F",
                "I_Soldier_AA_F","I_Soldier_AT_F","I_officer_F","I_Soldier_repair_F","I_soldier_F","I_Soldier_LAT_F","I_Soldier_lite_F","I_Soldier_SL_F","I_Soldier_TL_F"] call BIS_fnc_selectRandom;
		_grpMember = _infantryGroup createUnit [_unit, _randomPos, [], 0, "FORM"];
	};

    [_infantryGroup, _smPos, _radiusSize / 1.6] call FNC(taskPatrol);
    [_infantryGroup, "SME"] call FNC(setUnitSkill);

};


//-------------------------------------------------- AA groups

for "_x" from 1 to _AAGroupsAmount do {
    private _randomPos = [[[_smPos, _radiusSize], []], ["water", "out"]] call BIS_fnc_randomPos;
    private _infantryGroup = [_randomPos, EAST, configfile >> "CfgGroups" >> "East" >> "OPF_T_F" >> "Infantry" >>" O_T_InfTeam_AA"] call BIS_fnc_spawnGroup;
    _spawnedGroups pushBack _infantryGroup;

    [_infantryGroup, _smPos, _radiusSize / 1.6] call FNC(taskPatrol);
    [_infantryGroup, "SME"] call FNC(setUnitSkill);
};

//-------------------------------------------------- AT groups

for "_x" from 1 to _ATGroupsAmount do {
    private _randomPos = [[[_smPos, _radiusSize], []], ["water", "out"]] call BIS_fnc_randomPos;
    private _infantryGroup = [_randomPos, EAST, (configfile >> "CfgGroups" >> "East" >> "OPF_T_F" >> "Infantry" >> "O_T_InfTeam_AT")] call BIS_fnc_spawnGroup;
    _spawnedGroups pushBack _infantryGroup;

    [_infantryGroup, _smPos, _radiusSize / 1.6] call FNC(taskPatrol);
    [_infantryGroup, "SME"] call FNC(setUnitSkill);
};

[_spawnedGroups, _spawnedVehicles]