/*
Function: YAINA_MM_OBJ_fnc_radioTower

Description:
	The enemy has taken control of a few radio towers to call in jets for CAS.
    Uses the Main AO faction for populating the mission.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Quiksilver - Original Mission Idea
    Martin - Ported to YAINA
    MitchJC - Random Faction Selection
*/

#include "..\..\defines.h"

params ["_key", "_AOPos", "_AOSize", "_parentMissionID", "_army"];

// We always start with these 4, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings", "_MarkerColour"];

_markers    = [];
_units      = []; // To clean up units + groups at end
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.

_MarkerColour = "colorOPFOR";
_side = east;
if (_army isEqualto "AAF") then {
    _MarkerColour = "ColorGUER";
    _side = resistance; 
};

// Mission ID
_missionID = call FNC(getMissionID);

///////////////////////////////////////////////////////////
// Create cleanup Marker
///////////////////////////////////////////////////////////

_mrk = createMarker [format ["%1_mrk%2", _missionID, 0], _AOPos];
_mrk setMarkerShape "ELLIPSE";
_mrk setMarkerSize [_AOSize, _AOSize];
_mrk setMarkerBrush "Border";
_mrk setMarkerAlpha 0;
_markers pushBack _mrk;

///////////////////////////////////////////////////////////
// Spawn Towers
///////////////////////////////////////////////////////////


private ["_towerClasses", "_towerCount", "_towers", "_hidden", "_mines", "_towerMarkers"];

// Simple mission, try and create a radio tower in the AO somewhere vaugely in the AO - mission is complete when it's gone...
_towerClasses = [
    "Land_Communication_F",
    "Land_TTowerBig_1_F",
    "Land_TTowerBig_2_F"
];

_towerCount = floor(random 2);

_towers  = [];
_hideKey = format["HT_%1", _missionID];
_mines   = [];
_towermarkers = [];

for "_x" from 0 to _towerCount do {

    _towerClass = selectRandom _towerClasses;

    // Find safe pos isn't empty, so we should really not use it...just random point in marker
    _spawnPos = [_AOPos, 10, _AOSize, { !(_this isFlatEmpty [8, -1, 0.4, 10, 0, false, objNull] isEqualTo []) }] call YFNC(getPosAround);

    if (_spawnPos isEqualTo []) exitWith {
        ["Unable to find suitable location for tower", "ErrorLog"] call YFNC(log);
    };

    _tower = _towerClass createVehicle _spawnPos;
    [_tower, 0, 0] call BIS_fnc_setPitchBank;
    _towers pushBack _tower;

    // Hide any other objects in the area
    _tbbr = boundingBoxReal _tower;
    _r    = ((_tbbr select 0) distance2D (_tbbr select 1)) / 2;

    [clientOwner, _hideKey, _spawnPos, _r, _towers] remoteExec [QYFNC(hideTerrainObjects), 2];
    waitUntil { !isNil {  missionNamespace getVariable _hideKey } };
    missionNamespace setVariable [_hideKey, nil];

    // Mines?
    if ((round (random 1)) isEqualTo 1) then {
        for "_x" from 0 to 19 do {
            _m = createMine ["APERSBoundingMine", getPos _tower, [], 20];
            _bbr = boundingBoxReal _m;
            _bbh = (_bbr select 1 select 2) - (_bbr select 0 select 2) / 1.7;
            _p = getPosATL _m; _p set [2, -_bbh]; _m setPosATL _p;
            _mines pushBack _m;
        };
    };

    // Tower Markers
    private _mrks = [_missionID, [getPos _tower, 0, 100] call YFNC(getPosAround), 200, "loc_Transmitter", "Border", (_x * 2) + 1, _MarkerColour] call FNC(createMapMarkers);
    {_markers pushBack _x; true } count _mrks;

    // Build our towermarker array for cleanup
    _towerMarkers pushBack [_tower, _mrks];
};

// Ensure some are still alive
if ( ({alive _x} count _towers) isEqualTo 0) exitWith {
    missionNamespace setVariable [_key, false];
    nil
};

// Add them to zeus
[_towers + _mines] call YFNC(addEditableObjects);

// for clarity, use _buildings;
_buildings = _towers;

///////////////////////////////////////////////////////////
// Start Mission
///////////////////////////////////////////////////////////

[west,
    [_missionID, _parentMissionID],
    [
        "The enemy have took control of a few antennas, destroy them or they'll call air support.",
        "Destroy the Comms towers",
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
    _args params ["_missionID", "_stage", "_parentMissionID", "_towers", "_hideKey", "_mines", "_towerMarkers", "_AOPos", "_AOSize", "_jetSpawnTime", "_army"];


    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && { _stage < 2 } ) then {
        // Destroy the towers
        { _x setDamage 1; } forEach _towers;
    };

    if (_stage isEqualTo 1) then {

        // Bail if any towers are alive
        if !( call   {
                        {
                            _x params ["_twr", "_mrks"];
                            if (isNull _twr || !(alive _twr)) then {
                                { deleteMarker _x; } forEach _mrks;
                                false;
                            } else {
                                true
                            };
                        } count _towerMarkers;
                    } isEqualTo 0) exitWith {

            if (serverTime > _jetSpawnTime) then {
                // Call in a JET
                _args set [9, serverTime + 900 + random 300];
                [_AOPos, _AOSize, false, _army] remoteExecCall [QSFNC(cas), 2];
            };

        };

        // Give them some points, 100 per tower
        if !(_stopRequested) then {
            _points = 100 * (count _towers);
            [_points, "radioTowerObjective"] call YFNC(addRewardPoints);

            // Let them know
            parseText format ["<t align='center'><t size='2'>Sub Objective</t><br/><t size='1.5' color='#08b000'>COMPLETE</t><br/>____________________<br/><br/>Excellent work! That will certainly impact their ability to call in air support as we continue to progress towards the HQ<br/><br/>You have received %1 points.<br/><br/>Now focus on the remaining forces in the main objective area and make it back home safely!", _points] call YFNC(globalHint);
        };

        // Otherwise, success! go to cleanup
        [_missionID, 'Succeeded', not _stopRequested] call BIS_fnc_taskSetState;


        // Then we need to update the server's stage
        _args set[1,2];
        [_missionID, 2] call FNC(updateMission);
    };

    // Only clean up when parent mission gone
    if !(isNil "_parentMissionID") then {
        if (_parentMissionID call BIS_fnc_taskExists) then {
            if (!(_parentMissionID call BIS_fnc_taskCompleted)) then { breakOut "mainPFH"; };
        };
    };

    // We are now complete, let the server know we're in cleanup so it will spawn another AO
    if (_stage isEqualTo 2 ) then {
        _stage = 3;
        _args set [1,_stage];
        [_missionID, _stage, "CLEANUP"] call FNC(updateMission);
    };

    if (_stage isEqualTo 3) then {
        if ([_pfhID, _missionID] call FNC(missionCleanup)) then {
            [_hideKey] call YFNC(showTerrainObjects);

            { deleteVehicle _x; true } count _mines;
        };
    }
};

[_missionID, "SO", 1, format["radioTower subobj of %1", _parentMissionID], _parentMissionID, _markers, _units, _vehicles, _buildings, _pfh, 10, [_missionID, 1, _parentMissionID, _towers, _hideKey, _mines, _towerMarkers, _AOPos, _AOSize, serverTime + random 300, _army]] call FNC(startMissionPFH);

// Return that we were successful in starting the mission
missionNamespace setVariable [_key, _missionID];