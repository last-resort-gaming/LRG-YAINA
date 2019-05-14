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
    MitchJC - Rewritten for INA
    Martin - Ported to YAINA
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

_army = selectRandom ["AAF", "Syndikat", "CSAT Pacific"];

_army call {
    if (_this isEqualTo "AAF") exitWith {
		_side = resistance;
		_CampType = "CA";
		_MarkerColour = "ColorGUER";
		_MarkerMissionName = "Comms Station";
        [_side, _CampType, _MarkerColour, _MarkerMissionName];
    };
    if (_this isEqualTo "CSAT Pacific") exitWith {
        _side = east;
		_CampType = "CV";
		_MarkerColour = "colorOPFOR";
		_MarkerMissionName = "CSAT Camp";
        [_side, _CampType, _MarkerColour, _MarkerMissionName];
    };
    if (_this isEqualTo "Syndikat") exitWith {
		_side = resistance;
		_CampType = "CB";
		_MarkerColour = "ColorGUER";
		_MarkerMissionName = "Outpost";
        [_side, _CampType, _MarkerColour, _MarkerMissionName];
    };
} params ["_side", "_CampType", "_MarkerColour", "_MarkerMissionName"];

///////////////////////////////////////////////////////////
// Location Scout
///////////////////////////////////////////////////////////
private ["_AOPosition", "_CQPosition", "_loc", "_pos"];
private _AOSize = 400;

_pos = [_AOSize, "LAND", "FLAT"] call YFNC(AOPos);

_CQPosition = _pos select 0;

_AOPosition = _pos select 1;

_loc = _pos select 2;

private _missionDescription = format["Conquest at %1", _loc];

///////////////////////////////////////////////////////////
// Spawn Conquest HQ
///////////////////////////////////////////////////////////

private ["_cqFunc", "_CQElements"];

// Now we have our HQ + Location, bring in the HQ
_missionID = call FNC(getMissionID);

// Get our random HQ Spawn Function
_cqFunc = missionNamespace getVariable (selectRandom ( ["YAINA_SPAWNS_fnc", ["YAINA_SPAWNS", _CampType]] call YFNC(getFunctions) ));

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

// Spawn the Garrison
private _cg = [_CQPosition, [0,50], _army, 3] call SFNC(infantryGarrison);
_units append _cg;
[_cg, format["Conquest_Garrison_%1", _missionID]] call FNC(prefixGroups);

// Spawn the rest

([format["Conquest_%1", _missionID], _CQPosition, _AOSize*0.5, _army, [1, 0, _AOSize*0.5, "LRG Default", 6], [4,6, "LRG Default"], [1,0, "LRG Default"], [1,0, "LRG Default"], [1,0, "LRG Default"], [0,0], [1,1], [1,1], [0], [0,1]] call SFNC(populateArea)) params ["_spUnits", "_spVehs"];

_units append _spUnits;
_vehicles append _spVehs;

// Spawn Bunkers

for "_x" from 0 to (1 + (random 3)) do {

	_bunker = [_AOPosition, _AOSize * 0.75, _army, _missionID] call SFNC(bunker) params ["_bunits", "_bvehicles", "_bobjects"];

	_units append _bunits;

	_buildings append _bobjects;

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
        format ["Seize the %2 at %1", _loc, _MarkerMissionName],
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