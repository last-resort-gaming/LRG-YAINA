/*
Function: YAINA_MM_OBJ_fnc_conquest

Description:
	Conquest Objective. Randomly selects one of the following armies to theme
    and populate the mission:

    AAF, CSAT, CSAT Pacific, Syndikat

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
    Mokka - Original Mission Idea
    Martin - Ported to YAINA
    MitchJC - Random Faction Selection
    Matth - Compositions
*/
#include "..\..\defines.h"

// We always start with these 6, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings", "_side", "_INFTEAMS", "_CampType", "_unittypes", "_ConquestGroupType", "_RandomVeh", "_MarkerColour", "_MarkerMissionName"];

_markers    = [];
_units      = []; // To clean up units at end
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.

_army = selectRandom ["AAF","CSAT Pacific","Syndikat"];

switch (_army) do {

    case "AAF": {
		_side = resistance;
		_INFTEAMS = ["HAF_InfSquad","HAF_InfSquad_Weapons","HAF_InfTeam","I_InfTeam_Light"];
		_CampType = "CA";
		_unittypes = ["I_Soldier_A_F","I_Soldier_AR_F","I_medic_F","I_Soldier_M_F","I_Soldier_F","I_Soldier_LAT_F","I_Soldier_SL_F","I_Soldier_TL_F"];
		_ConquestGroupType = (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "SpecOps" >> selectRandom _INFTEAMS);
		_RandomVeh = ["I_G_Offroad_01_armed_F","I_MRAP_03_hmg_F"];
		_MarkerColour = "ColorGUER";
		_MarkerMissionName = "Comms Station";
		};
    case "CSAT Pacific": {
		_side = east;
		_INFTEAMS = ["OI_ViperTeam"];
		_CampType = "CV";
		_unittypes = ["O_V_Soldier_hex_F","O_V_Soldier_TL_hex_F","O_V_Soldier_Exp_hex_F","O_V_Soldier_Medic_hex_F","O_V_Soldier_M_hex_F","O_V_Soldier_LAT_hex_F","O_V_Soldier_JTAC_hex_F"];
		_ConquestGroupType = (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "SpecOps" >> selectRandom _INFTEAMS) ;
		_RandomVeh = ["O_T_LSV_02_armed_F", "O_T_MRAP_02_hmg_ghex_F", "O_T_LSV_02_AT_F", "O_T_LSV_02_unarmed_F"];
		_MarkerColour = "colorOPFOR";
		_MarkerMissionName = "Viper Camp";
		};
    case "Syndikat": {
		_side = resistance;
		_INFTEAMS = ["BanditCombatGroup","BanditFireTeam","BanditShockTeam","ParaCombatGroup","ParaFireTeam","ParaShockTeam"];
		_CampType = "CB";
		_unittypes = ["I_C_Soldier_Bandit_7_F","I_C_Soldier_Bandit_3_F","I_C_Soldier_Bandit_2_F","I_C_Pilot_F","I_C_Soldier_Bandit_6_F","I_C_Soldier_Bandit_1_F","I_C_Soldier_Bandit_8_F","I_C_Soldier_Bandit_4_F","I_C_Soldier_Para_5_F","I_C_Soldier_Para_1_F","I_C_Soldier_Para_8_F","I_C_Soldier_Para_6_F","I_C_Soldier_Para_4_F","I_C_Soldier_Para_3_F","I_C_Soldier_Para_2_F","I_C_Soldier_Para_7_F"];
		_ConquestGroupType = (configfile >> "CfgGroups" >> "Indep" >> "IND_C_F" >> "Infantry" >> selectRandom _INFTEAMS) ;
		_RandomVeh = ["I_G_Offroad_01_armed_F","I_C_Offroad_02_LMG_F","I_C_Offroad_02_AT_F","I_C_Offroad_02_unarmed_F"];
		_MarkerColour = "ColorGUER";
		_MarkerMissionName = "Outpost";
		};
    default {
		_side = resistance;
		_INFTEAMS = ["HAF_InfSquad","HAF_InfSquad_Weapons","HAF_InfTeam","I_InfTeam_Light"];
		_CampType = "CA";
		_unittypes = ["O_V_Soldier_hex_F","O_V_Soldier_TL_hex_F","O_V_Soldier_Exp_hex_F","O_V_Soldier_Medic_hex_F","O_V_Soldier_M_hex_F","O_V_Soldier_LAT_hex_F","O_V_Soldier_JTAC_hex_F"];
		_ConquestGroupType = (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "SpecOps" >> selectRandom _INFTEAMS);
		_RandomVeh = ["I_G_Offroad_01_armed_F"];
		_MarkerColour = "ColorGUER";
		_MarkerMissionName = "Comms Station";
		};
};

///////////////////////////////////////////////////////////
// Location Scout
///////////////////////////////////////////////////////////

private ["_AOPosition", "_CQPosition", "_nearestTown"];
private _AOSize = 400;

_CQPosition = [0,0];
while { _CQPosition isEqualTo [0,0] } do {
    _CQPosition = [nil, ([_AOSize] call FNC(getAOExclusions)) + ["water"], {
        { _x distance2D _this < (_AOSize * 2) } count allPlayers isEqualTo 0 && !(_this isFlatEmpty [-1,-1,0.25,25,0,false] isEqualTo [])
    }] call BIS_fnc_randomPos;
};

// Now find a location for our AO center position fuzz the HQ...
_AOPosition = [_CQPosition, 20, _AOSize*0.9] call YFNC(getPosAround);

// Find our nearest town + direction for mission description
_nearestTown = [_AOPosition] call YFNC(dirFromNearestName);

// Mission Description
private _missionDescription = format["Conquest: %1 of %2", _nearestTown select 2, text (_nearestTown select 0)];

///////////////////////////////////////////////////////////
// Spawn Conquest HQ
///////////////////////////////////////////////////////////

private ["_cqFunc", "_CQElements"];

// Now we have our HQ + Location, bring in the HQ
_missionID = call FNC(getMissionID);

// Get our random HQ Spawn Function
_cqFunc = missionNamespace getVariable (selectRandom ( ["YAINA_SPAWNS_fnc", ["YAINA_SPAWNS", _CampType]] call FNC(getFunctions) ));

// Hide any terrain and slam down the HQ
private _hiddenTerrainKey = format["HT_%1", _missionID];
[clientOwner, _hiddenTerrainKey, _CQPosition, 30] remoteExec [QYFNC(hideTerrainObjects), 2];

// Wait for the server to send us back
waitUntil { !isNil {  missionNamespace getVariable _hiddenTerrainKey } };

_CQElements  = [_CQPosition, random 360, call _cqFunc] call BIS_fnc_ObjectsMapper;
_buildings   = _CQElements;

///////////////////////////////////////////////////////////
// Spawn AI
///////////////////////////////////////////////////////////

// use the largest building around as our CQ Building
private _CQBuildingInfo = [_CQPosition, 30] call FNC(findLargestBuilding);
if (_CQBuildingInfo isEqualTo []) exitWith {};

private _CQBuilding = _CQBuildingInfo select 0;

_priorityGroup = createGroup _side;
_priorityGroup setGroupIdGlobal [format['cq_gar1_%1', _missionID]];

_garrisonpos = _CQBuildingInfo select 1;
_buildingposcount = count _garrisonpos;

for "_i" from 1 to _buildingposcount do {
    _unittype = selectrandom _unittypes;
    _unitpos  = selectrandom _garrisonpos;
    _unit     = _priorityGroup createUnit [_unittype, _unitpos, [],0,"NONE"];
    _garrisonpos = _garrisonpos - [_unitpos];
    _units pushBack _unit;

    private _returnedUnits = [_CQBuildingInfo select 0,(units _priorityGroup), 100, true, true, 0] call derp_fnc_ZenOccupy;
    { deleteVehicle _x } foreach _returnedUnits;
};

_priorityGroup setGroupIdGlobal [format['cq_gar2_%1', _missionID]];

private _ConquestInfAmount = 0;

for "_x" from 0 to (4 + (random 2)) do {
    private _randomPos = [[[_CQPosition, 200],[]],["water","out"]] call BIS_fnc_randomPos;

    private _ConquestGroup = createGroup _side;
    _ConquestGroup = [_randomPos, _side, _ConquestGroupType] call BIS_fnc_spawnGroup;
    _units append (units _ConquestGroup);

    _ConquestInfAmount = _ConquestInfAmount + 1;
    _ConquestGroup setGroupIdGlobal [format ['cq_inf%1_%2', _x, _missionID]];

    [_ConquestGroup, _CQPosition, 100] call BIS_fnc_taskPatrol;
    [_ConquestGroup, 3] call SFNC(setUnitSkill);

};

private _ConquestVehAmmount = 0;
for "_x" from 0 to (2 + (random 3)) do {
    private _randomPos = [[[_CQPosition, 300],[]],["water","out"]] call BIS_fnc_randomPos;
    private _vehc = (selectRandom _RandomVeh) createVehicle _randompos;

    _vehc allowCrewInImmobile true;
    _vehc lock 2;
    _vehicles pushBack _vehc;

    private _grp1 = createGroup _side;

    _ConquestVehAmmount = _ConquestVehAmmount + 1;
    _grp1 setGroupIdGlobal [format ['cq_veh%1_%2', _x, _missionID]];

    _unit = _grp1 createUnit [(selectRandom _UnitTypes), _randomPos, [],0,"NONE"];
    _unit assignAsDriver _vehc;
    _unit moveInDriver _vehc;
    _units pushBack _unit;


    _unit = _grp1 createUnit [(selectRandom _UnitTypes), _randomPos, [],0,"NONE"];
    _unit assignAsGunner _vehc;
    _unit moveInGunner _vehc;
    _units pushBack _unit;

    [_grp1, _CQPosition, 100] call BIS_fnc_taskPatrol;
    _grp1 setSpeedMode "LIMITED";

};


///////////////////////////////////////////////////////////
// Start Mission
///////////////////////////////////////////////////////////

// Bring in the Markers
_markers = [_missionID, _AOPosition, _AOSize, nil, nil, nil, _MarkerColour] call FNC(createMapMarkers);

// Add everything to zeus
[_units + _buildings + _vehicles, true] call YFNC(addEditableObjects);

// Set the mission in progress
[
    west,
    _missionID,
    [
        format ["There's an enemy %1 being set up. Move in and take it out.",_MarkerMissionName],
        format ["Seize the %3 %1 of %2", _nearestTown select 2, text (_nearestTown select 0), _MarkerMissionName],
        ""
    ],
    _AOPosition,
    false,
    10,
    true,
    "Attack",
    true
] call BIS_fnc_taskCreate;


// Build the progression PFH
_pfh = {
    scopeName "mainPFH";

    params ["_args", "_pfhID"];
    _args params ["_missionID", "_stage", "_hiddenTerrainKey", "_CQElements"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && {_stage < 3}) then { _stage = 2; };

    // Now make sure we have claered most the AI
    if (_stage isEqualTo 1 && { not _stopRequested }) then {

        _alive = { alive _x } count ([_missionID] call FNC(getMissionUnits));

        if (_alive < 4) then {
            _stage = 2; _args set [1,_stage];
        };
    };

    // We have stage 2 just to set the params to avoid executing it each time whilst waiting for cleanup
    if (_stage isEqualTo 2) then {

        // Give them some points
        if !(_stopRequested) then {
            [1000, "conquest"] call YFNC(addRewardPoints);
            parseText format ["<t align='center' size='2.2'>Conquest Mission</t><br/><t size='1.5' align='center' color='#34DB16'> Conquest Objective Secured</t><br/>____________________<br/>Good work out there. You have received %1 credits to compensate your efforts!", 1000] call YFNC(globalHint);
        };

        _stage = 3; _args set [1,_stage];

        [_missionID, 'Succeeded', not _stopRequested] call BIS_fnc_taskSetState;
        [_missionID, _stage, "CLEANUP"] call FNC(updateMission);

    };

    if (_stage isEqualTo 3) then {
        // Initiate default cleanup function to clean up officer group + group
        if ([_pfhID, _missionID, _stopRequested] call FNC(missionCleanup)) then {

            // Once cleanup occurs, we do anything that isn't the default
            { deleteVehicle _x; true; } count _CQElements;

            [_hiddenTerrainKey] remoteExec [QYFNC(showTerrainObjects), 2];
        };
    };
};


// Enable players to drop onto this mission
[(_markers select 0)] call FNC(setupParadrop);

// For now just start it
[_missionID, "IO", 1, _missionDescription, "", _markers, _units, _vehicles, _buildings, _pfh, 5, [_missionID, 1, _hiddenTerrainKey, _CQElements]] call FNC(startMissionPFH);
