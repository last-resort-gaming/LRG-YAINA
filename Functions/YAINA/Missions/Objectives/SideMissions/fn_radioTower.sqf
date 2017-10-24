/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\..\defines.h"

params ["_AOPos", "_AOSize", "_parentMissionID"];

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

_towers = [];
_hidden = [];
_mines  = [];
_towermarkers = [];

for "_x" from 0 to _towerCount do {

    _towerClass = selectRandom _towerClasses;

    // Find safe pos isn't empty, so we should really not use it...just random point in marker
    _spawnPos = [_AOPos, 10, _AOSize, { !(_this isFlatEmpty [-1, -1, 0.4, 10, 0, false, objNull] isEqualTo []) }] call YFNC(getPosAround);

    if (_spawnPos isEqualTo []) then {
        diag_log "Unable to find suitable location for tower";
    };

    _tower = _towerClass createVehicle _spawnPos;
    [_tower, 0, 0] call BIS_fnc_setPitchBank;
    _towers pushBack _tower;

    // Hide any other objects in the area
    _tbbr = boundingBoxReal _tower;
    _r    = ((_tbbr select 0) distance2D (_tbbr select 1)) / 2;

    _hidden = _hidden + ([_spawnPos, _r, _towers] call YFNC(hideTerrainObjects));

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
    private _mrks = [_missionID, [getPos _tower, 0, 100] call YFNC(getPosAround), 200, "loc_Transmitter", "Border", (_x * 2) + 1] call FNC(createMapMarkers);
    {_markers pushBack _x; true } count _mrks;

    // Build our towermarker array for cleanup
    _towerMarkers pushBack [_tower, _mrks];
};

// Ensure some are still alive
if ( ({alive _x} count _towers) isEqualTo 0) exitWith {nil};

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
        "OPFOR have took control of a few antennas, destroy them or they'll call air support.",
        "Destroy OPFOR comms towers",
        ""
    ],
    objNull,
    "Created",
    5,
    false,
    "destroy",
    true
] call BIS_fnc_taskCreate;

_pfh = {

    scopeName "mainPFH";

    params ["_args", "_pfhID"];
    _args params ["_missionID", "_stage", "_parentMissionID", "_towers", "_hidden", "_mines", "_towerMarkers"];

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
                    } isEqualTo 0) exitWith {};

        // Give them some points, 100 per tower
        _points = 100 * (count _towers);
        [_points, "radioTowerObjective"] call YFNC(addRewardPoints);

        // Let them know
        parseText format ["<t align='center'><t size='2'>Sub Objective</t><br/><t size='1.5' color='#08b000'>COMPLETE</t><br/>____________________<br/><br/>Excellent work! That will certainly impact the OPFORs ability to call in air support as we continue to progress towards the HQ<br/><br/>You have received %1 points.<br/><br/>Now focus on the remaining forces in the main objective area and make it back home safely!", _points] call YFNC(globalHint);

        // Otherwise, success! go to cleanup
        [_missionID, 'Succeeded', true] call BIS_fnc_taskSetState;

        // Then we need to update the server's stage
        _args set[1,2];
        [_missionID, 2] call FNC(updateMissionStage);
    };

    // Only clean up when parent mission gone
    if !(isNil "_parentMissionID") then {
        if (_parentMissionID call BIS_fnc_taskExists) then {
            if (!(_parentMissionID call BIS_fnc_taskCompleted)) then { breakOut "mainPFH"; };
        };
    };

    // We are now complete, let the server know we're in cleanup so it will spawn another AO
    // We don't need to update the server here as worst case is that this gets executed again
    // if this HC disconnects
    if (_stage isEqualTo 2) then {
        [_missionID, "CLEANUP"] call FNC(updateMissionState);
        _args set [1,3];
    };

    if ([_pfhID, _missionID] call FNC(missionCleanup)) then {
        [_hidden] call YFNC(showTerrainObjects);

        { deleteVehicle _x; true } count _mines;
    };
};

[_missionID, "SO", 1, _markers, _groups, _vehicles, _buildings, _pfh, 10, [_missionID, 1, _parentMissionID, _towers, _hidden, _mines, _towerMarkers]] call FNC(startMissionPFH);

// Return that we were successful in starting the mission
_missionID;