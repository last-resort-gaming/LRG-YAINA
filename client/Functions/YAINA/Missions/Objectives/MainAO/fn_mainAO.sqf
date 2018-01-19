/*
	author: Martin
	description: none
	returns: nothing
*/
#include "..\..\defines.h"

// We always start with these 4, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_groups", "_vehicles", "_buildings"];

_markers    = [];
_groups     = []; // To clean up units + groups at end
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.

///////////////////////////////////////////////////////////
// Location Scout
///////////////////////////////////////////////////////////

private ["_blacklistAreas", "_AOPosition", "_HQPosition", "_blacklistAreas", "_nearestTown"];
private _AOSize = 600;

// pick a random MAIN AO spawn that's 2 * _AOSize away from players + other AOs
_blacklistAreas = BASE_PROTECTION_AREAS + ["water"] + GVAR(paradropMarkers);

_HQPosition = [nil, _blacklistAreas, {
    { _x distance2D _this < (_AOSize * 2) } count allPlayers isEqualTo 0 && !(_this isFlatEmpty [-1,-1,0.25,25,0,false,objNull] isEqualTo [])
}] call BIS_fnc_randomPos;

// Its okay to bail, the mission manager will try again...
if (_HQPosition isEqualTo []) exitWith {
    TRACE_1("mainAO: Failed to find location", _location);
};

// Now find a location for our AO center position fuzz the HQ...
_AOPosition = [_HQPosition, 0, _AOSize, 0, 0, 0, 0, [], []] call BIS_fnc_findSafePos;

if (_AOPosition isEqualTo []) exitWith {
    TRACE_1("findSafePos: Failed to find safe location from", _HQPosition);
};

// Find our nearest town + direction for mission description
_nearestTown = [_AOPosition] call YFNC(dirFromNearestName);

// Mission Description
private _missionDescription = format["Main AO: %1 of %2", _nearestTown select 2, text (_nearestTown select 0)];

///////////////////////////////////////////////////////////
// Spawn Mission
///////////////////////////////////////////////////////////

private ["_hqFunc", "_officerGroup", "_HQElements", "_officerPos", "_officer"];

// Now we have our HQ + Location, bring in the HQ
_missionID = call FNC(getMissionID);

// Get our random HQ Spawn Function
_hqFunc = selectRandom (
            ("true" configClasses (missionconfigfile >> "CfgFunctions" >> "YAINA_SPAWNS" >> "HQ")) apply {
                missionNamespace getVariable format["YAINA_SPAWNS_fnc_%1", configName _x]
            }
          );

// Hide any terrain and slam down the HQ
private _hiddenTerrainKey = format["HT_%1", _missionID];
[clientOwner, _hiddenTerrainKey, _HQPosition, 30] remoteExec [QYFNC(hideTerrainObjects), 2];

// Wait for the server to send us back
waitUntil { !isNil {  missionNamespace getVariable _hiddenTerrainKey } };

_HQElements         = [_HQPosition, random 360, call _hqFunc] call BIS_fnc_ObjectsMapper;
_buildings          = _HQElements;

// Bring in an officer to one of the buildings
_officerPos = call {
    _officerBuilding    = selectRandom (nearestObjects [_HQPosition, ["house", "building"], 30] select { !(isObjectHidden _x || count (_x buildingPos -1) isEqualTo 0) });
    _officerBuildingPos = _officerBuilding buildingPos -1;
    _officerBuildingPos select round(random(count (_officerBuildingPos) - 1));
};

// Spawn Officer
_officerGroup = createGroup east;
_officer = _officerGroup createUnit ["O_Officer_F", _officerPos ,[],0,"NONE"];
_groups pushBack _officerGroup;

// Add event handler on that officer so we know who dun it
_officer addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator"];

    _instigatorReal = _instigator;
    if (_instigator isEqualTo objNull) then {
        if (_killer isKindOf "UAV") then {
            _instigatorReal = (UAVControl _killer) select 0;
        } else {
            // Dunno...someoen
            _instigatorReal = _killer;
        };
    };

    parseText format ["<t align='center'><t size='2'>Main Objective</t><br/><t size='1.5' color='#08b000'>PROGRESS</t><br/>____________________<br/><br/>Well done %1! You have killed the Officer stationed in the HQ.<br/><br/>Now, move in on the HQ and defend it from the enemy forces that remain in the area!", name _instigatorReal] call YFNC(globalHint);
}];

// Spawn some Infantry Groups with small patrol radius
for "_x" from 0 to 8 do {
    _groups pushBack ([[_AOPosition, 0, _AOSize] call YFNC(getPosAround), ((_AOSize/8) + (random _AOSize/4))  ] call SFNC(infantryPatrol));
};

// Garrison squads around the HQ
private _garrisonedGroups = ([_HQPosition, 30] call SFNC(infantryGarrison));
{ _groups pushBack _x; true; } count _garrisonedGroups;

// Garrison squads around the AO
_garrisonedGroups = ([_AOPosition + [0], _AOSize, 5] call SFNC(infantryGarrison));
{ _groups pushBack _x; true; } count _garrisonedGroups;


// Bring in the Markers
_markers = [_missionID, _AOPosition, _AOSize] call FNC(createMapMarkers);

// Add everything to zeus
[_buildings + [_officer], true] call YFNC(addEditableObjects);

///////////////////////////////////////////////////////////
// Start Mission
///////////////////////////////////////////////////////////

// Set the mission in progress
[
    west,
    _missionID,
    [
        format ["OPFOR have setup an HQ %1 from %2, you need to clear it out! Good luck and don't forget to complete the side mission we're assigning you.", _nearestTown select 2, text (_nearestTown select 0)],
        format ["Clear HQ %1 of %2", _nearestTown select 2, text (_nearestTown select 0)],
        ""
    ],
    _AOPosition,
    true,
    10,
    true,
    "Attack",
    true
] call BIS_fnc_taskCreate;

///////////////////////////////////////////////////////////
// Find Side Mission, Needs to be after Main mission start
// so that it becomes a child of it
///////////////////////////////////////////////////////////

private _idx = 5;
_sms = ("true" configClasses (missionconfigfile >> "CfgFunctions" >> "YAINA_MM_OBJ" >> "SideMissions")) apply {
            missionNamespace getVariable format["YAINA_MM_OBJ_fnc_%1", configName _x]
       };

_subObjective = nil;

while { _idx > 0 && isNil "_subObjective" } do {
    _k = format["SO_%1", _missionID];
    [_k, _AOPosition, _AOSize, _missionID] call (selectRandom _sms);
    waitUntil { !isNil { missionNamespace getVariable _k } };
    _mm = missionNamespace getVariable _k;
    if (_mm isEqualTo false) then {
        _idx = _idx - 1;
    } else {
        _subObjective = _mm;
    };
    missionNamespace setVariable [_k, nil];
};

// Build the progression PFH
_pfh = {

    scopeName "mainPFH";

    params ["_args", "_pfhID"];
    _args params ["_missionID", "_stage", "_subObjective", "_hiddenTerrainKey", "_HQElements", "_officerGroup", "_HQPosition"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && { _stage < 3 }) then {
        // Jump right to stage 3
        _stage = 3;
    };

    if (_stage isEqualTo 1) then {

        if (isNull _officerGroup || count ((units _officerGroup) select { alive _x; }) isEqualTo 0) then {
            // Whooo officer killed, move to stage 2

            // We create a task, to defend the HQ that's really an extension of this task...
            [
                WEST,
                [format ["%1_defend", _missionID], _missionID],
                [
                    format ["OPFOR have setup an HQ %1 from %2, you need to clear it out! Good luck and don't forget to complete the side mission we're assigning you.", _nearestTown select 2, text (_nearestTown select 0)],
                    "Defend the HQ",
                    ""
                ],
                _HQPosition,
                true,
                10,
                true,
                "Defend",
                false
            ] call BIS_fnc_taskCreate;

            // Create Marker
            _mrk = createmarker [format ["%1_defend_mrk", _missionID], _HQPosition];
            _mrk setMarkerShape "ELLIPSE";
            _mrk setMarkerSize [100, 100];
            _mrk setMarkerBrush "Solid";
            _mrk setMarkerColor "ColorPink";
            _mrk setMarkerAlpha 0.5;

            [_missionID, 2] call FNC(updateMissionStage);
            _args set [1,2];

            // Now set units to surround the HQ...
            {
                // Allow them ot move etc.
                {
                    _x enableAI "AUTOCOMBAT";
                    _x enableAI "PATH";
                    true;
                } count (units _x);

                // Remove waypoints, and get them to move to HQ
                while { (!((count waypoints _x) isEqualTo 0)) } do {
                  deleteWaypoint ((waypoints _x) select 0);
                };
                _x addWaypoint [_HQPosition, 30];

            } forEach ([_missionID] call FNC(getMissionGroups));
        };
    };

    if (_stage isEqualTo 2) then {

        // If we are in stage2, then we sit here until most of the enemy are dead and SMs have completed

        // If we have a subObjective, ensure it's complete before progressing
        if !(isNil "_subObjective") then {
            if (_subObjective call BIS_fnc_taskExists) then {
                if (!(_subObjective call BIS_fnc_taskCompleted)) then { breakOut "mainPFH"; };
            };
        };

        // Now make sure we have
        _alive = 0;
        { _alive = _alive + ({ alive _x } count units _x); } forEach ([_missionID] call FNC(getMissionGroups));

        if (_alive < 20) then {

            // Complete our dummy task + delete it's marker
            deleteMarker format ["%1_defend_mrk", _missionID];

            // Just delete the task, main task takes care of it
            [format ["%1_defend", _missionID]] call BIS_fnc_deleteTask;

            // And move on to mission windup, we don't do it here
            // as the PFH resumes until folks are outside the AO
            // and we don't want it to redo this all the time.
            [_missionID, 3] call FNC(updateMissionStage);
            _args set [1,3];
        };
    };

    // Lastly, start our cleanup
    if (_stage isEqualTo 3) then {

        // Set Mission Exit State
        [_missionID, 'Succeeded', not _stopRequested] call BIS_fnc_taskSetState;

        [_missionID, "CLEANUP"] call FNC(updateMissionState);
        _args set [1,4];
        _stage = 4;
    };

    if (_stage isEqualTo 4) then {

        // Initiate default cleanup function to clean up officer group + group
        if ([_pfhID, _missionID, _stopRequested] call FNC(missionCleanup)) then {

            // Once cleanup occurs, we do anything that isn't the default
            { deleteVehicle _x; true; } count _HQElements;

            [_hiddenTerrainKey] remoteExec [QYFNC(showTerrainObjects), 2];
        };
    };
};

// Enable players to drop onto this mission
[(_markers select 0)] call FNC(setupParadrop);

// For now just start it
[_missionID, "AO", 1, _missionDescription, "", _markers, _groups, _vehicles, _buildings, _pfh, 10, [_missionID, 1, _subObjective, _hiddenTerrainKey, _HQElements, _officerGroup, _HQPosition]] call FNC(startMissionPFH);
