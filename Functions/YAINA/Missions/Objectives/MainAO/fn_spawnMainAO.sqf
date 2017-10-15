/*
	author: Martin
	description: none
	returns: nothing
*/
#include "..\..\defines.h"

// This needs to be as quick as possible as it will hang HCs/Server
// Even if you spawned it, it would hang as the actual command itself
// is not interruptable from a scheduled perspective...so quick and
// sloppy, and let hideTerrainObjects save the day

// pick a random MAIN AO spawn that's 1500 away from players
_location = [];
while { _location isEqualTo [] } do {
    _pot = selectRandom GVAR(MAO_Locations);
    _pos = _pot select 1;
    if (call { { _x distance2D myPos < 1500 } count allPlayers; } isEqualTo 0) then {
        _location = _pot;
    };
};

// Now find a home for the HQ;
_HQPosition  = [];
_hqPots = selectBestPlaces [_location select 1, 800, "forest + trees + meadow - houses - (10 * sea)", 10, 10];
while { !(count _hqPots isEqualTo 0 && _HQPosition isEqualTo []) } do {
    _idx = round(random count _hqPots);
    _pos = (_hqPots select _idx) select 0;

    if ((_pos isFlatEmpty [-1,-1,3,30,0,false,objNull]) isEqualTo []) then {
        _hqPots deleteAt _idx;
    } else {
        _HQPosition = _pos;
    };
};

// Its okay to bail, the mission manager will try again...
if (_found isEqualTo []) exitWith {};

// Now we have our HQ + Location, bring in the HQ

_missionID = call FNC(getMissionID);

_AOName     = _location select 0;
_AOPosition = _location select 1;
_AOSize     = 800;
_groups     = [];
_vehicles   = [];

// Get all our HQ Spawns
_hqOpts = [];
{ _hqOpts pushBack (missionNamespace getVariable format["YAINA_SPAWNS_fnc_%1", configName _x]); } forEach ("true" configClasses (missionconfigfile >> "CfgFunctions" >> "YAINA_SPAWNS" >> "HQ"));

// Hide any terrain and slam down the HQ
_hiddenTerrainElems = [_HQPosition, 30] call YFNC(hideTerrainObjects);
_HQElements         = [_HQPosition, random 360, call selectRandom _hqOpts] call BIS_fnc_ObjectsMapper;
_enemyGroups        = [];

// Bring in an officer to one of the buildings
_officerBuilding    = selectRandom (nearestObjects [_HQPosition, ["house", "building"], 30] select { !(isObjectHidden _x || count (_x buildingPos -1) isEqualTo 0) });
_officerBuildingPos = _officerBuilding buildingPos -1;
_officerPos         = _officerBuildingPos select round(random(count (_officerBuildingPos) - 1));

TRACE_2("spawnMainAO", _officerBuilding, _officerPos);

_officerGroup = createGroup east;
_officerGroup createUnit ["O_Officer_F", _officerPos ,[],0,"NONE"];
_groups pushBack _officerGroup;

// Bring in the Markers
_markers = [_missionID, _AOPosition, _AOSize] call FNC(createMapMarkers);

// Add everything to zeus
[_HQElements + units _officerGroup, true] call YFNC(addEditableObjects);

// Set the mission in progress
[
    west,
    _missionID,
    [
        format ["%1 has been captured, you need to clear it out! Good luck and don't forget to complete the side mission we're assigning you.", _AOName ],
        format ["Clear %1", _AOName],
        ""
    ],
    _AOPosition,
    true,
    10,
    true,
    "Attack",
    true
] call BIS_fnc_taskCreate;


// Build the progression PFH
_pfh = {

    params ["_args", "_pfhID"];
    _args params ["_missionID",  "_hiddenTerrainElems", "_HQElements", "_officerGroup"];

    // Check the entire officer group is dead (or doesn't exist any more)
    if (isNull _officerGroup || count ((units _officerGroup) select { alive _x; }) isEqualTo 0) then {

        // Set Mission Exit State
        [_missionID, 'Succeeded', true] call BIS_fnc_taskSetState;

        // Groups
        _groups pushBack _officerGroup;

        // Initiate default cleanup function to clean up officer group + group
        if ([_missionID] call FNC(missionCleanup)) then {

            // Once cleanup occurs, we do anything that isn't the default
            { deleteVehicle _x; true; } count _HQElements;

            [_hiddenTerrainElems] call YFNC(showTerrainObjects);

            // remove the PFH so it's no longer running
            [_missionID, _pfhID] call FNC(endMissionPFH);

        };
    };
};

// For now just start it
[_missionID, "MAINAO", _markers, _groups, _vehicles, _HQElements, _pfh, 10, [_missionID, _hiddenTerrainElems, _HQElements, _officerGroup]] call FNC(startMissionPFH);
