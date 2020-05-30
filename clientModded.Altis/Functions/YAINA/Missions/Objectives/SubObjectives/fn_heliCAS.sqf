/*
Function: YAINA_MM_OBJ_fnc_heliCAS

Description:
	The enemy has set up a FAC tower to guide their helicopter-powered CAS.
    Uses the Main AO faction for populating the mission.

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

params ["_key", "_AOPos", "_AOSize", "_parentMissionID", "_army"];

// We always start with these 4, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings", "_FacType", "_MarkerType", "_MarkerColour"];

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
		_FacType = "O_recon_JTAC_F";
		_MarkerType = "O_installation";
		_MarkerColour = "colorOPFOR";
        [_FacType, _MarkerType, _MarkerColour, east];
	};

	if (_this isEqualto "AAF") exitwith {
		_FacType = "I_soldier_UAV_F";
		_MarkerType = "n_installation";
		_MarkerColour = "ColorGUER";
        [_FacType, _MarkerType, _MarkerColour, resistance];
	};

	if (_this isEqualto "CSAT Pacific") exitwith {
		_FacType = "O_T_Recon_JTAC_F";
		_MarkerType = "O_installation";
		_MarkerColour = "colorOPFOR";
        [_FacType, _MarkerType, _MarkerColour, east];
	};
} params ["_FacType", "_MarkerType", "_MarkerColour", "_side"];

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
// Spawn tower
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

// Spawn our tower
private _towerClasses = [
    "Land_Cargo_Tower_V1_F",
    "Land_Cargo_Tower_V2_F",
    "Land_Cargo_Tower_V3_F"
];
private _towerClass = selectRandom _towerClasses;
private _tower = _towerClass createVehicle _ObjectPosition;
_tower setDir random 360;
_tower allowDamage false; //no CAS bombing it until the fac inside is killed.
_buildings pushBack _tower;

// tower Markers
private _mrks = [_missionID, [_ObjectPosition, 0, 100] call YFNC(getPosAround), 200, _MarkerType, "Border", nil, _MarkerColour] call FNC(createMapMarkers);
{_markers pushBack _x; true } count _mrks;

// Spawn fac

// Bring in an fac to one of the buildings
private _facPos = selectRandom (_tower call BIS_fnc_buildingPositions);
private _facGroup = createGroup _side;
_facGroup setGroupIdGlobal [format["tower_eng_%1", _missionID]];
private _fac = _facGroup createUnit [_FacType, [0,0,0], [],0,"NONE"];
_fac setPos _facPos;
_units pushBack _fac;

// Add event handler on that fac so we know who dun it
_fac addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator"];

    _instigatorReal = _instigator;
    if (_instigator isEqualTo objNull) then {
        if (_killer isKindOf "UAV") then {
            _instigatorReal = (UAVControl _killer) select 0;
        } else {
            _instigatorReal = _killer;
        };
    };

    parseText format ["<t align='center'><t size='2'>Sub Objective</t><br/><t size='1.5' color='#08b000'>PROGRESS</t><br/>____________________<br/><br/>The FAC  has been killed by %1. Move in and demo that tower!", [name _instigatorReal, "someone"] select (isNull _instigatorReal)] call YFNC(globalHint);
}];

// Garrison some around the tower
private _fgn = [_ObjectPosition, [0,50], _army, 1, nil, nil, 6, [_facPos]] call SFNC(infantryGarrison);
_units append _fgn;
[_fgn, format["tower_gar_%1", _missionID]] call FNC(prefixGroups);

// And a few to populate the immediate area
([format["tower_pa_%1", _missionID], _ObjectPosition, 100, _army, [0], [2,2], [0], [0], [0], [0,1], [0], [0], [0,1], [0,1]] call SFNC(populateArea)) params ["_spUnits", "_spVehs"];

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
        "Enemy Forces have built a FAC tower to guide in HeliCAS. First kill the FAC inside then demo that building.",
        "Sub Objective: HeliCAS Tower",
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
    _args params ["_missionID", "_stage", "_parentMissionID", "_hideKey", "_markers", "_fac", "_tower", "_AOPos", "_AOSize", "_heliSpawnTime"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && { _stage < 3 } ) then {
        _stage = 3;
    };

    // Wait for the fac to be killed
    if (_stage isEqualTo 1) then {

        if (alive _fac) then {

				if ((serverTime > _heliSpawnTime) && !(_heliSpawnTime isEqualTo 0)) then {
                // Call in a HELI
                _args set [9, serverTime + 900 + random 300];
                [_AOPos, _AOSize, false, _army] remoteExecCall [QSFNC(helicas), 2];
            };

        } else {
            // Mov on
           _args set[1,2];
           [_missionID, 2] call FNC(updateMission);

           _tower allowDamage true;
        };
    };

    // We now wait for tower to be destroyed
    if (_stage isEqualTo 2) then {
        if !(alive _tower) then {
           _stage = 3; _args set [1,_stage];
        };
    };

    // And now we just wait for cleanup
    if (_stage isEqualTo 3) then {

        // Give them some points, 100 per tower
        if !(_stopRequested) then {
            [350, "tower"] call YFNC(addRewardPoints);
            parseText format ["<t align='center'><t size='2'>Sub Objective</t><br/><t size='1.5' color='#08b000'>COMPLETE</t><br/>____________________<br/><br/>Excellent work! That will certainly impact their ability to call in air support as we continue to progress towards the HQ<br/><br/>You have received %1 points.<br/><br/>Now focus on the remaining forces in the main objective area and make it back home safely!", 350] call YFNC(globalHint);
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

[_missionID, "SO", 1, format["tower subobj of %1", _parentMissionID], _parentMissionID, _markers, _units, _vehicles, _buildings, _pfh, 10, [_missionID, 1, _parentMissionID, _hideKey, _markers, _fac, _tower, _AOPos, _AOSize, 0, 1]] call FNC(startMissionPFH);

// Return that we were successful in starting the mission
missionNamespace setVariable [_key, _missionID];