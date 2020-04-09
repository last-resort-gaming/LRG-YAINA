/*
Function: YAINA_MM_OBJ_fnc_factory

Description:
	The enemy has set up a vehicle factory. Take it out before the enemy is able to
    reinforce their troops.
    Uses the Main AO faction for populatin the mission.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Lost Bullet - Original Mission Idea
    Martin - Ported to YAINA
    MitchJC - Random Faction Selection
*/

#include "..\..\defines.h"

params ["_key", "_AOPos", "_AOSize", "_parentMissionID", "_army", "_side"];

// We always start with these 4, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings", "_randomveh", "_EngineerType", "_RandomGroup", "_MarkerType"];

_markers    = [];
_units      = []; // To clean up units + groups at end
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.



_army call {
	_side = east;
	if (_this isEqualto "CSAT") exitwith {
		_randomveh = [
			"O_APC_Tracked_02_cannon_F",
			"O_APC_Wheeled_02_rcws_v2_F",
			"O_MRAP_02_hmg_F",
			"O_MRAP_02_gmg_F",
			"O_LSV_02_AT_F",
			"O_LSV_02_armed_F",
			"O_APC_Tracked_02_AA_F",
			"O_MBT_02_cannon_F",
			"O_MBT_04_cannon_F",
			"O_MBT_04_command_F"
			];
		_EngineerType = "O_engineer_F";
		_RandomGroup = configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> (selectRandom ["OIA_InfTeam","OI_reconPatrol"]);
		_MarkerType = "O_installation";
		_MarkerColour = "colorOPFOR";
        [_randomveh, _EngineerType, _RandomGroup, _MarkerType, _MarkerColour, east];
	};

	if (_this isEqualto "AAF") exitwith {
		_randomveh = [
			"I_LT_01_AA_F",
			"I_APC_Wheeled_03_cannon_F",
			"I_APC_tracked_03_cannon_F",
			"I_MRAP_03_gmg_F",
			"I_MRAP_03_hmg_F",
			"I_LT_01_AT_F",
			"I_LT_01_scout_F",
			"I_LT_01_cannon_F",
			"I_MBT_03_cannon_F"
			];
		_EngineerType = "I_engineer_F";
		_RandomGroup = configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry" >> (selectRandom ["HAF_InfTeam","I_InfTeam_Light"]);
		_MarkerType = "n_installation";
		_MarkerColour = "ColorGUER";
		_side = resistance;
        [_randomveh, _EngineerType, _RandomGroup, _MarkerType, _MarkerColour, resistance];
	};

	if (_this isEqualto "CSAT Pacific") exitwith {
		_randomveh = [
			"O_T_APC_Tracked_02_AA_ghex_F",
			"O_T_APC_Tracked_02_cannon_ghex_F",
			"O_T_APC_Wheeled_02_rcws_v2_ghex_F",
			"O_T_MRAP_02_gmg_ghex_F",
			"O_T_MRAP_02_hmg_ghex_F",
			"O_T_LSV_02_AT_F",
			"O_T_LSV_02_armed_F",
			"O_T_MBT_04_cannon_F",
			"O_T_MBT_02_cannon_ghex_F",
			"O_T_MBT_04_command_F"
			];
		_EngineerType = "O_T_Engineer_F";
		_RandomGroup = configfile >> "CfgGroups" >> "East" >> "OPF_T_F" >> "Infantry" >> (selectRandom ["O_T_InfTeam","O_T_reconPatrol"]);
		_MarkerType = "O_installation";
		_MarkerColour = "colorOPFOR";
        [_randomveh, _EngineerType, _RandomGroup, _MarkerType, _MarkerColour, east];
	};
} params ["_randomveh", "_EngineerType", "_RandomGroup", "_MarkerType", "_MarkerColour", "_side"];

// Mission ID
_missionID = call FNC(getMissionID);

///////////////////////////////////////////////////////////
// Create cleanup Marker
///////////////////////////////////////////////////////////

private _mrk = createMarker [format ["%1_mrk%2", _missionID, 0], _AOPos];
_mrk setMarkerShape "ELLIPSE";
_mrk setMarkerSize [_AOSize, _AOSize];
_mrk setMarkerBrush "Border";
_mrk setMarkerAlpha 0;
_markers pushBack _mrk;

///////////////////////////////////////////////////////////
// Spawn Factory
///////////////////////////////////////////////////////////

// Find safe pos isn't empty, so we should really not use it...just random point in marker

private _ObjectPosition = [0,0];
while { _ObjectPosition isEqualTo [0,0] } do {
    _ObjectPosition = [_AOPos, 10, _AOSize, { !(_this isFlatEmpty [4, -1, 0.4, 10, 0, false, objNull] isEqualTo []) }] call YFNC(getPosAround);
};

// Clear some are around it
private _hideKey = format["HT_%1", _missionID];
[clientOwner, _hideKey, _ObjectPosition, 20] remoteExec [QYFNC(hideTerrainObjects), 2];
waitUntil { !isNil {  missionNamespace getVariable _hideKey } };
missionNamespace setVariable [_hideKey, nil];

// Spawn our Factory
private _factory = "Land_I_Shed_Ind_F" createVehicle _ObjectPosition;
_factory setDir random 360;
_factory allowDamage false; //no CAS bombing it until the Engineer inside is killed.
_buildings pushBack _factory;

// Factory Markers
private _mrks = [_missionID, [_ObjectPosition, 0, 100] call YFNC(getPosAround), 200, _MarkerType, "Border", nil, _MarkerColour] call FNC(createMapMarkers);
{_markers pushBack _x; true } count _mrks;
// Spawn Engineer

// Bring in an engineer to one of the buildings
private _engineerPos = selectRandom (_factory call BIS_fnc_buildingPositions);
private _engineerGroup = createGroup _side;
_engineerGroup setGroupIdGlobal [format["factory_eng_%1", _missionID]];
private _engineer = _engineerGroup createUnit [_EngineerType, [0,0,0], [],0,"NONE"];
_engineer setPos _engineerPos;
_units pushBack _engineer;

// Add event handler on that engineer so we know who dun it
_engineer addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator"];

    _instigatorReal = _instigator;
    if (_instigator isEqualTo objNull) then {
        if (_killer isKindOf "UAV") then {
            _instigatorReal = (UAVControl _killer) select 0;
        } else {
            _instigatorReal = _killer;
        };
    };

    parseText format ["<t align='center'><t size='2'>Sub Objective</t><br/><t size='1.5' color='#08b000'>PROGRESS</t><br/>____________________<br/><br/>The enemy engineer has been killed by %1. Move in and demo that Factory!", [name _instigatorReal, "someone"] select (isNull _instigatorReal)] call YFNC(globalHint);
}];

// Garrison some around the Factory
private _fgn = [_ObjectPosition, [0,50], _army, 1, nil, nil, 6, [_engineerPos]] call SFNC(infantryGarrison);
_units append _fgn;
[_fgn, format["factory_gar_%1", _missionID]] call FNC(prefixGroups);

// And a few to populate the immediate area
([format["factory_pa_%1", _missionID], _ObjectPosition, 100, _army, [0], [2,2], [0], [0], [0], [0,1], [0], [0], [0,1], [0,1]] call SFNC(populateArea)) params ["_spUnits", "_spVehs"];

// Add to Zeus
_vehicles append _spVehs;
_units append _spUnits;

// Add everything to zeus
[ _units + _vehicles + _buildings, false] call YFNC(addEditableObjects);

// Mark the outside units as reinforcements of the main AO, so they move in when the officer is killed, but leaving the garrisoned troops in
[_parentMissionID, _spUnits, _spVehs] call FNC(addReinforcements);

///////////////////////////////////////////////////////////
// Start Mission
///////////////////////////////////////////////////////////

[west,
    [_missionID, _parentMissionID],
    [
        "The enemies have set up a factory. Enemy reinforcements will keep coming to the AO until this factory is taken out! Intel suggest that the factory looks like a big industrial shed. First kill the engineer inside then demo that building.",
        "Sub Objective: Factory",
        ""
    ],
    objNull,
    "Created",
    0,
    false,
    "destroy",
    true
] call BIS_fnc_taskCreate;

_pfh = {

    scopeName "mainPFH";

    params ["_args", "_pfhID"];
    _args params ["_missionID", "_stage", "_parentMissionID", "_hideKey", "_markers", "_engineer", "_factory", "_AOPos", "_AOSize", "_nextSpawnTime", "_spawnCount", "_randomveh", "_side", "_RandomGroup"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && { _stage < 3 } ) then {
        _stage = 3;
    };

    // Wait for the engineer to be killed
    if (_stage isEqualTo 1) then {

        if (alive _engineer) then {
            // Do we spawn ?
            if (LTIME > _nextSpawnTime) then {
                _inAO = { _x distance2D _AOPos < _AOSize } count allPlayers;
                if (_inAO < 1) then {
                    _args set [9, LTIME + 120];
                } else {
                    // We have enough folks to spawn something :)
                    _spawned = false;

                    if ((random 1) > 0.3) then {
                        // Infantry - 2 AI per player in AI, rounded to nearest 4
                        _groupCount = ceil(_inAO / 2);

                        _spUnits = [];
                        for "_x" from 1 to _groupCount do {

                            // Try 3 times before moving on
                            private _ObjectPosition = [0,0];
                            private _attempt = 0;
                            while { _ObjectPosition isEqualTo [0,0] && { _attempt < 3 } } do {
                                _ObjectPosition = [[[_AOPos, _AOSize]], ["water"], {
                                    { if(_x distance2D _this < 300) exitWith { 1 }; false; } count allPlayers isEqualTo 0
                                }] call BIS_fnc_randomPos;
                                _attempt = _attempt + 1;
                            };

                            if !(_ObjectPosition isEqualTo [0,0]) then {

                                _g = [_ObjectPosition, _side, _RandomGroup] call BIS_fnc_spawnGroup;
                                _g setGroupIdGlobal [format["factory_spu_%1_%2_inf%4", _missionID, _spawnCount , _x]];

                                // If the defend mission is up, we set the position to be around the HQ, else we keep them around the AO
                                _defendTask = format["%1_defend", _parentMissionID];
                                if (_defendTask call BIS_fnc_taskExists) then {
                                    [_g, [getPos (leader _g), _defendTask call BIS_fnc_taskDestination, (20 + random 30)] call YFNC(getPointBetween), 40, 3] call CBA_fnc_taskPatrol;
                                } else {
                                    [_g, _AOPos, _AOSize/1.5, 3 + round (random 2), "SAD", ["AWARE", "SAFE"] select (random 1 > 0.5), ["red", "white"] select (random 1 > 0.2), ["limited", "normal"] select (random 1 > 0.5)] call CBA_fnc_taskPatrol;
                                };

                                [_g, "LRG Default"] call SFNC(setUnitSkill);
                                _spUnits append (units _g);
                            }
                        };

                        if !(_spUnits isEqualTo []) then {
                            _spawned = true;

                            // Add to zeus
                            [_spUnits, false] call YFNC(addEditableObjects);

                            // Add to reinforcements
                            [_parentMissionID, _spUnits, []] call FNC(addReinforcements);
                        };

                    } else {
                        // Vehicle

                        _attempts = 4;
                        _rpos = [0,0];
                        while { _rpos isEqualTo [0,0] && { _attempts > 0 } } do {
                            _rpos = [[[_AOPos, _AOSize]], ["water"], {
                                !(_this isFlatEmpty [2,-1,0.5,1,0,false,objNull] isEqualTo []) && { { if( _x distance2D _this < 300) exitWith { 1 }; false; } count allPlayers isEqualTo 0 }
                             }] call BIS_fnc_randomPos;
                            _attempts = _attempts -1;
                            [format["IN A RPOS LOOP %1 (%2)", _rpos, _AOPos]] call YFNC(log);
                        };

                        if !(_rpos isEqualTo [0,0]) then {

                            _spawned = true;

                            _grp = createGroup _side;
                            _grp setGroupIdGlobal [format["factory_spv_%1_%2", _missionID, _spawnCount]];

                            _veh = (selectRandom _Randomveh) createVehicle _rpos;
                            [_veh, _grp] call BIS_fnc_spawnCrew;

                            _veh lock 3;
                            _veh allowCrewInImmobile true;

                            _defendTask = format["%1_defend", _parentMissionID];
                            if (_defendTask call BIS_fnc_taskExists) then {
                                [_grp, [getPos (leader _grp), _defendTask call BIS_fnc_taskDestination, (20 + random 30)] call YFNC(getPointBetween), 40, 3] call CBA_fnc_taskPatrol;
                            } else {
                                [_grp, _AOPos, _AOSize/2] call BIS_fnc_taskPatrol;
                            };

                            _grp setBehaviour "COMBAT";
                            _grp setCombatMode "RED";

                            _spunits = units _grp;

                            // Add to zeus
                            [_spunits + [_veh]] call YFNC(addEditableObjects);

                            [_grp, "LRG Default"] call SFNC(setUnitSkill);

                            [_parentMissionID, _spunits, [_veh]] call FNC(addReinforcements);
                        };
                    };

                    if !(_spawned) then {
                        // Try again in 30 seconds if no spawn
                        _args set [9, LTIME + 30];
                    } else {

                        // New sleeptime
                        if (_inAO < 15) then{
                            _args set [9, LTIME + 480];
                        } else {
                            _args set [9, LTIME + (480 - floor (_inAO * 4))];
                        };

                        // Increment spawn count
                        _args set[10, _spawnCount + 1];
                    };
                };
            };
        } else {
            // Mov on
           _args set[1,2];
           [_missionID, 2] call FNC(updateMission);

           _factory allowDamage true;
        };
    };

    // We now wait for factory to be destroyed
    if (_stage isEqualTo 2) then {
        if !(alive _factory) then {
           _stage = 3; _args set [1,_stage];
        };
    };

    // And now we just wait for cleanup
    if (_stage isEqualTo 3) then {

        // Give them some points, 100 per tower
        if !(_stopRequested) then {
            [350, "factory"] call YFNC(addRewardPoints);
            parseText format ["<t align='center'><t size='2'>Sub Objective</t><br/><t size='1.5' color='#08b000'>COMPLETE</t><br/>____________________<br/><br/>Excellent work! That will certainly impact their ability to call in ground reinforcements as we continue to progress towards the HQ<br/><br/>You have received %1 points.<br/><br/>Now focus on the remaining forces in the main objective area and make it back home safely!", 350] call YFNC(globalHint);
        };

        // Otherwise, success! go to cleanup
        [_missionID, 'Succeeded', not _stopRequested] call BIS_fnc_taskSetState;

        // Move onto stage 4
        _stage = 4; _args set [1,_stage];
        [_missionID, _stage] call FNC(updateMission);

        // Hide our markers
        { _x setMarkerAlpha 0; } count _markers;

    };

    // Only clean up when parent mission gone
    if !(isNil "_parentMissionID") then {
        if (_parentMissionID call BIS_fnc_taskExists) then {
            if (!(_parentMissionID call BIS_fnc_taskCompleted)) then { breakOut "mainPFH"; };
        };
    };

    // We are now complete, let the server know we're in cleanup so it will spawn another AO
    if (_stage isEqualTo 4 ) then {
        _stage = 5; _args set [1,_stage];
        [_missionID, _stage, "CLEANUP"] call FNC(updateMission);
    };

    if (_stage isEqualTo 5) then {
        if ([_pfhID, _missionID] call FNC(missionCleanup)) then {
            [_hideKey] call YFNC(showTerrainObjects);
        };
    };
};

[_missionID, "SO", 1, format["factory subobj of %1", _parentMissionID], _parentMissionID, _markers, _units, _vehicles, _buildings, _pfh, 10, [_missionID, 1, _parentMissionID, _hideKey, _markers, _engineer, _factory, _AOPos, _AOSize, 0, 1, _randomveh, _side, _RandomGroup]] call FNC(startMissionPFH);

// Return that we were successful in starting the mission
missionNamespace setVariable [_key, _missionID];