/*
	author: Martin
	description:
	    Mission inspired by Lost Bullet / INA
	returns: nothing
*/

#include "..\..\defines.h"

params ["_key", "_AOPos", "_AOSize", "_parentMissionID"];

// We always start with these 4, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_groups", "_vehicles", "_buildings"];

_markers    = [];
_groups     = []; // To clean up units + groups at end
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.

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

// Spawn Engineer

// Bring in an engineer to one of the buildings
private _engineerPos = selectRandom (_factory call BIS_fnc_buildingPositions);
private _engineerGroup = createGroup east;
_engineerGroup setGroupIdGlobal [format["%1 eng", _missionID]];
private _engineer = _engineerGroup createUnit ["O_V_Soldier_Exp_hex_F", [0,0,0], [],0,"NONE"];
_engineer setPos _engineerPos;
_groups pushBack _engineerGroup;

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

    parseText format ["<t align='center'><t size='2'>Sub Objective</t><br/><t size='1.5' color='#08b000'>PROGRESS</t><br/>____________________<br/><br/>The OPFOR engineer has been killed by %1. Move in and demo that Factory!", [name _instigatorReal, "someone"] select (isNull _instigatorReal)] call YFNC(globalHint);
}];

// Garrison some around the Factory
private _fgn = [_ObjectPosition, [0,50], east, 1, nil, nil, 6, [_engineerPos]] call SFNC(infantryGarrison);
{ _groups pushBack _x; _x setGroupIdGlobal [format["%1_fgn%2", _missionID, _forEachIndex]]; } forEach _fgn;

// And a few to populate the immediate area
([_missionID, _ObjectPosition, 100, east, [0], [2,2], [0], [0], [0], [0,1], [0], [0], [0,1], [0,1]] call SFNC(populateArea)) params ["_spGroups", "_spVehs"];

// Add to Zeus
_vehicles append _spVehs;
_groups append _spGroups;

// Add everything to zeus
{ [units _x] call YFNC(addEditableObjects); true; } count _groups;
[ _vehicles + _buildings, true] call YFNC(addEditableObjects);

// Mark the outside units as reinforcements of the main AO, so they move in when the officer is killed, but leaving the garrisoned troops in
[_parentMissionID, _spGroups, _spVehs] call FNC(addReinforcements);

///////////////////////////////////////////////////////////
// Start Mission
///////////////////////////////////////////////////////////

[west,
    [_missionID, _parentMissionID],
    [
        "The enemies have set up a factory. Enemy reinforcements will keep coming to the AO untill this factory is taken out! Intell suggest that the factory looks like a big industrial shed. First kill the engineer inside then demo that building.",
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
    _args params ["_missionID", "_stage", "_parentMissionID", "_hideKey", "_engineer", "_factory", "_AOPos", "_AOSize", "_nextSpawnTime"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && { _stage < 3 } ) then {
        _stage = 3;
    };

    // Wait for the engineer to be killed
    if (_stage isEqualTo 1) then {

        if (alive _engineer) then {
            // Do we spawn ?
            if (serverTime > _nextSpawnTime) then {
                _inAO = { _x distance2D _AOPos < _AOSize } count allPlayers;
                if (_inAO < 1) then {
                    _args set [8, serverTime + 120];
                } else {
                    // We have enough folks to spawn something :)

                    if ((random 1) > 0.3) then {
                        // Infantry - 2 AI per player in AI, rounded to nearest 4
                        _groupCount = ceil(_inAO / 2);

                        // we populate them to the entire AO as a normal pop
                        (["factory", _AOPos, _AOSize, east, [0], [_groupCount], [0], [0], [0], [0], [0], [0], [0], [0]] call SFNC(populateArea)) params ["_spGroups", "_spVehs"];

                        // Add to zeus
                        { [units _x] call YFNC(addEditableObjects); true; } count _spGroups;

                        // Add to reinforcements
                        [_parentMissionID, _spGroups, []] call FNC(addReinforcements);

                    } else {
                        // Vehicle

                        _attempts = 4;
                        _rpos = [0,0];
                        while { _rpos isEqualTo [0,0] && { _attempts > 0 } } do {
                            _rpos = [[[_AOPos, _AOSize], []], ["water", "out"], { !(_this isFlatEmpty [2,-1,0.5,1,0,false,objNull] isEqualTo []) }] call BIS_fnc_randomPos;
                            _attempts = _attempts -1;
                            diag_log format["IN A RPOS LOOP %1 (%2)", _rpos, _AOPos];
                        };

                        if !(_rpos isEqualTo [0,0]) then {

                            _grp = createGroup east;
                            _grp setGroupIdGlobal ["factory veh"];

                            _veh = (selectRandom ["O_MBT_02_cannon_F","O_APC_Tracked_02_cannon_F","O_APC_Wheeled_02_rcws_F","O_MRAP_02_gmg_F","O_MRAP_02_hmg_F","O_APC_Tracked_02_AA_F"]) createVehicle _rpos;
                            [_veh, _grp] call BIS_fnc_spawnCrew;

                            _veh lock 3;
                            _veh allowCrewInImmobile true;

                            [_grp, _AOPos, _AOSize/2] call BIS_fnc_taskPatrol;
                            _grp setBehaviour "COMBAT";
                            _grp setCombatMode "RED";

                            // Add to zeus
                            [units _grp + [_veh]] call YFNC(addEditableObjects);

                            [_grp, 3] call SFNC(setUnitSkill);

                            [_parentMissionID, [_grp], [_veh]] call FNC(addReinforcements);
                        };
                    };

                    // New sleeptime
                    if (_inAO < 15) then{
                        _args set [8, serverTime + 480];
                    } else {
                        _args set [8, serverTime + (480 - floor (_inAO * 4))];
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
            parseText format ["<t align='center'><t size='2'>Sub Objective</t><br/><t size='1.5' color='#08b000'>COMPLETE</t><br/>____________________<br/><br/>Excellent work! That will certainly impact the OPFORs ability to call in ground reinforcements as we continue to progress towards the HQ<br/><br/>You have received %1 points.<br/><br/>Now focus on the remaining forces in the main objective area and make it back home safely!", 350] call YFNC(globalHint);
        };

        // Otherwise, success! go to cleanup
        [_missionID, 'Succeeded', not _stopRequested] call BIS_fnc_taskSetState;

        // Move onto stage 4
        _stage = 4; _args set [1,_stage];
        [_missionID, _stage] call FNC(updateMission);
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

[_missionID, "SO", 1, format["radioTower subobj of %1", _parentMissionID], _parentMissionID, _markers, _groups, _vehicles, _buildings, _pfh, 10, [_missionID, 1, _parentMissionID, _hideKey, _engineer, _factory, _AOPos, _AOSize, 0]] call FNC(startMissionPFH);

// Return that we were successful in starting the mission
missionNamespace setVariable [_key, _missionID];