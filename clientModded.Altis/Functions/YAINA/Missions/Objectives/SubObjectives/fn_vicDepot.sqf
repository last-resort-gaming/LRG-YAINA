/*
Function: YAINA_MM_OBJ_fnc_vicDepot

Description:
	The enemy has set up a vehicle depot. Destroy it before the depot's armament overruns
    you.

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
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings", "_vehtype", "_crewtype", "_FuelTruck","_MarkerType","_MarkerColour"];

_markers    = [];
_units      = []; // To clean up units + groups at end
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.


_army call {
	if (_this isEqualto "CSAT") exitwith {
		_vehtype = ["O_MBT_02_cannon_F", "O_MBT_04_cannon_F", "O_MBT_04_command_F"];
		_crewtype = "O_crew_F";
		_FuelTruck = "O_Truck_03_fuel_F";
		_MarkerType = "O_installation";
		_MarkerColour = "colorOPFOR";
	    _side = east;
        [_vehtype, _crewtype, _FuelTruck, _MarkerType, _MarkerColour, _side];
	};

	if (_this isEqualto "AAF") exitwith {
		_vehtype = ["I_MBT_03_cannon_F", "I_LT_01_cannon_F", "I_LT_01_AT_F"];
		_crewtype = "I_crew_F";
		_FuelTruck = "I_Truck_02_fuel_F";
		_MarkerType = "n_installation";
		_MarkerColour = "ColorGUER";
		_side = resistance;
        [_vehtype, _crewtype, _FuelTruck, _MarkerType, _MarkerColour, _side];
	};

	if (_this isEqualto "CSAT Pacific") exitwith {
		_vehtype = ["O_T_MBT_02_cannon_ghex_F", "O_T_MBT_04_cannon_F", "O_T_MBT_04_command_F"];
		_crewtype = "O_T_Crew_F";
		_FuelTruck = "O_T_Truck_03_fuel_ghex_F";
		_MarkerType = "O_installation";
		_MarkerColour = "colorOPFOR";
	    _side = east;
        [_vehtype, _crewtype, _FuelTruck, _MarkerType, _MarkerColour, _side];
	};
} params ["_vehtype", "_crewtype", "_FuelTruck", "_MarkerType", "_MarkerColour", "_side"];

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
// Spawn Depot
///////////////////////////////////////////////////////////

// Find safe pos isn't empty, so we should really not use it...just random point in marker

private _ObjectPosition = [0,0];
while { _ObjectPosition isEqualTo [0,0] } do {
    _ObjectPosition = [_AOPos, 10, _AOSize, { !(_this isFlatEmpty [4, -1, 0.4, 10, 0, false, objNull] isEqualTo []) }] call YFNC(getPosAround);
};

// Clear some are around it
private _hideKey = format["HT_%1", _missionID];
[clientOwner, _hideKey, _ObjectPosition, 30] remoteExec [QYFNC(hideTerrainObjects), 2];
waitUntil { !isNil {  missionNamespace getVariable _hideKey } };
missionNamespace setVariable [_hideKey, nil];

// Spawn our Depot
private _depot = "Land_Shed_Big_F" createVehicle _ObjectPosition;
_depot setDir 90;
_depot allowDamage false; //Give CAS a challenge if called in
private _repair = "Land_RepairDepot_01_green_F" createVehicle (_ObjectPosition vectorAdd [-17,18,0]);
_repair setDir 230;
_repair lock true;
private _fuel = _FuelTruck createVehicle (_ObjectPosition vectorAdd [16,18,0]);
_fuel setDir 330;
private _crate = "Box_ind_ammoveh_F" createVehicle (_ObjectPosition vectorAdd [14,0,0]);
_crate setDir 330;
_buildings append [_depot, _repair];

// Depot Markers
private _mrks = [_missionID, [_ObjectPosition, 0, 100] call YFNC(getPosAround), 200, _MarkerType, "Border", nil, _MarkerColour] call FNC(createMapMarkers);
{_markers pushBack _x; true } count _mrks;

// Spawn Vehicles
private _veh1 = (selectRandom _vehtype) createVehicle (_ObjectPosition vectorAdd [-0.5,17,0]);
private _vehPos = getPos _veh1;
_veh1 lock true;
_veh1 setDir 1;
private _veh2 = (selectRandom _vehtype) createVehicle (_ObjectPosition vectorAdd [4,17.2,0]);
private _vehPos2 = getPos _veh2;
_veh2 lock true;
_veh2 setDir 12;
private _veh3 = (selectRandom _vehtype) createVehicle (_ObjectPosition vectorAdd [-4,17.2,0]);
private _vehPos3 = getPos _veh3;
_veh3 lock true;
_veh1 setDir 8;
_vehicles append [_veh1, _veh2, _veh3, _fuel, _crate];


//Spawn Crew

private _vicGroup1 = createGroup _side;
_vicGroup1 setGroupIdGlobal [format["vic1_crew_%1", _missionID]];
private _driver1 = _vicGroup1 createUnit [_crewtype, (_vehPos vectorAdd [0,-5,0]), [],0,"NONE"];
private _gunner1 = _vicGroup1 createUnit [_crewtype, (_vehPos vectorAdd [0,-5,0]), [],0,"NONE"];
_vicGroup1 setBehaviour "CARELESS";
_vicGroup1 setCombatMode "BLUE";

private _vicGroup2 = createGroup _side;
_vicGroup2 setGroupIdGlobal [format["vic2_crew_%1", _missionID]];
private _driver2 = _vicGroup2 createUnit [_crewtype, (_vehPos2 vectorAdd [0,-5,0]), [],0,"NONE"];
private _gunner2 = _vicGroup2 createUnit [_crewtype, (_vehPos2 vectorAdd [0,-5,0]), [],0,"NONE"];
_vicGroup2 setBehaviour "CARELESS";
_vicGroup2 setCombatMode "BLUE";

private _vicGroup3 = createGroup _side;
_vicGroup3 setGroupIdGlobal [format["vic3_crew_%1", _missionID]];
private _driver3 = _vicGroup3 createUnit [_crewtype, (_vehPos3 vectorAdd [0,-5,0]), [],0,"NONE"];
private _gunner3 = _vicGroup3 createUnit [_crewtype, (_vehPos3 vectorAdd [0,-5,0]), [],0,"NONE"];
_vicGroup3 setBehaviour "CARELESS";
_vicGroup3 setCombatMode "BLUE";

_units append [_driver1, _driver2, _driver3, _gunner1, _gunner2, _gunner3];

// Garrison some around the Depot
private _fgn = [_ObjectPosition, [0,50], _army, 1, nil, nil, 6, _ObjectPosition] call SFNC(infantryGarrison);
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
        "The enemies have set up a Vehicle Depot. Enemy reinforcements are preparing to leave the Depot and deploy into the AO! Intell suggest that the Depot looks like a big vehicle shed housing tanks. Kill the crew or destroy the tanks!",
        "Sub Objective: Vehicle Depot",
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
    _args params ["_missionID", "_stage", "_parentMissionID", "_hideKey", "_markers", "_AOPos", "_AOSize", "_nextSpawnTime", "_spawnCount", "_bracket", "_veh1", "_veh2", "_veh3", "_driver1", "_driver2", "_driver3", "_gunner1", "_gunner2", "_gunner3", "_vicGroup1", "_vicGroup2", "_vicGroup3", "_crewtype", "_ObjectPosition"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && { _stage < 3 } ) then {
        _stage = 3;
    };

    // Wait for crew killed or vehicles killed or all deployed
    if (_stage isEqualTo 1) then {
		if (((alive _veh1) || (alive _veh2) || (alive _veh3)) && ((alive _driver1) || (alive _driver2) || (alive _driver3)) && !(_spawnCount isEqualTo 3)) then {
            if (LTIME > _nextSpawnTime) then {
                _inAO = { _x distance2D _AOPos < _AOSize } count allPlayers;
                if (_inAO < 1) then {
                    _args set [7, LTIME + 120];
					} else {
                    // We have enough folks to spawn something :)
					_spawned = false;
					if ((alive _veh1) && (_spawned isEqualTo false) && (_bracket isEqualTo 0)) then {
						if (alive _driver1) then {
						_driver1 moveInDriver _veh1;
						_gunner1 moveInGunner _veh1;
						} else {
						private _driver1B = _vicGroup1 createUnit [_crewtype, _ObjectPosition, [],0,"NONE"];
						_driver1B moveInDriver _veh1;
						};
                        _defendTask = format["%1_defend", _parentMissionID];
                        if (_defendTask call BIS_fnc_taskExists) then {
							[_vicGroup1, [getPos (leader _vicGroup1), _defendTask call BIS_fnc_taskDestination, (20 + random 30)] call YFNC(getPointBetween), 40, 3] call CBA_fnc_taskPatrol;
                        } else {
                            [_vicGroup1, _AOPos, _AOSize/2] call BIS_fnc_taskPatrol;
                        };
						_vicGroup1 setBehaviour "COMBAT";
						_vicGroup1 setCombatMode "WHITE";

						_spawned = true;
						_args set [8, 1];
						_args set [9,1];
					};
					if ((alive _veh2) && (_spawned isEqualTo false)  && !(_bracket isEqualTo 2)) then {
						if (alive _driver2) then {
						_driver2 moveInDriver _veh2;
						_gunner2 moveInGunner _veh2;
						} else {
						private _driver2B = _vicGroup2 createUnit [_crewtype, _ObjectPosition, [],0,"NONE"];
						_driver2B moveInDriver _veh2;
						};
                        _defendTask = format["%1_defend", _parentMissionID];
                        if (_defendTask call BIS_fnc_taskExists) then {
							[_vicGroup2, [getPos (leader _vicGroup1), _defendTask call BIS_fnc_taskDestination, (20 + random 30)] call YFNC(getPointBetween), 40, 3] call CBA_fnc_taskPatrol;
                        } else {
                            [_vicGroup2, _AOPos, _AOSize/2] call BIS_fnc_taskPatrol;
                        };
						_vicGroup2 setBehaviour "COMBAT";
						_vicGroup2 setCombatMode "WHITE";
						_spawned = true;
						_args set [8, 2];
						_args set [9,2];
					};
					if ((alive _veh3) && (_spawned isEqualTo false) && !(_bracket isEqualTo 3)) then {
						if (alive _driver3) then {
						_driver3 moveInDriver _veh3;
						_gunner3 moveInGunner _veh3;
						} else {
						private _driver3B = _vicGroup3 createUnit [_crewtype, _ObjectPosition, [],0,"NONE"];
						_driver3B moveInDriver _veh2;
						};
                        _defendTask = format["%1_defend", _parentMissionID];
                        if (_defendTask call BIS_fnc_taskExists) then {
							[_vicGroup3, [getPos (leader _vicGroup1), _defendTask call BIS_fnc_taskDestination, (20 + random 30)] call YFNC(getPointBetween), 40, 3] call CBA_fnc_taskPatrol;
                        } else {
                            [_vicGroup3, _AOPos, _AOSize/2] call BIS_fnc_taskPatrol;
                        };
						_vicGroup3 setBehaviour "COMBAT";
						_vicGroup3 setCombatMode "WHITE";
						_spawned = true;
						_args set [8, 3];
						_args set [9,3];
						parseText format ["<t align='center'><t size='2'>Sub Objective</t><br/><t size='1.5' color='#08b000'>PROGRESS</t><br/>____________________<br/><br/>All deployable vehicles from the Depot have been released. Hunt and kill all the tanks!", [name _instigatorReal, "someone"] select (isNull _instigatorReal)] call YFNC(globalHint);
					};

                    if !(_spawned) then {
                        // Try again in 30 seconds if no spawn
                        _args set [7, LTIME + 30];
                    } else {

                        // New sleeptime
                        if (_inAO < 15) then{
                            _args set [7, LTIME + 900];
                        } else {
                            _args set [7, LTIME + (900 - floor (_inAO * 4))];
                        };
                    };
                };
            };
        } else {
            // Mov on
           _args set[1,2];
           [_missionID, 2] call FNC(updateMission);
        };
    };

    // Check if drivers alive
    if (_stage isEqualTo 2) then {
        if (!(alive _driver1) && !(alive _driver2) && !(alive _driver3)) then {
           _stage = 3; _args set [1,_stage];
        };
    };

    // Check if vehicles alive
    if (_stage isEqualTo 2) then {
        if (!(alive _veh1) && !(alive _veh2) && !(alive _veh3)) then {
           _stage = 3; _args set [1,_stage];
        };
    };

    // And now we just wait for cleanup
    if (_stage isEqualTo 3) then {

        // Give them some points, 100 per tower
        if !(_stopRequested) then {
            [350, "vicDepot"] call YFNC(addRewardPoints);
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

[_missionID, "SO", 1, format["factory subobj of %1", _parentMissionID], _parentMissionID, _markers, _units, _vehicles, _buildings, _pfh, 10, [_missionID, 1, _parentMissionID, _hideKey, _markers, _AOPos, _AOSize, 0, 1, 0, _veh1, _veh2, _veh3, _driver1, _driver2, _driver3, _gunner1, _gunner2, _gunner3, _vicGroup1, _vicGroup2, _vicGroup3, _crewtype, _ObjectPosition]] call FNC(startMissionPFH);

// Return that we were successful in starting the mission
missionNamespace setVariable [_key, _missionID];