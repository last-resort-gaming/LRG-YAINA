/*
Function: YAINA_MM_OBJ_fnc_mainAO

Description:
	The Main AO, primary objective in the mission life cycle.
    Randomly selects one of the following armies for the mission:

    AAF, CSAT, CSAT Pacific

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin, Matth and MitchJC
*/
#include "..\..\defines.h"

// We always start with these 4, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings", "_side", "_officerClass", "_MarkerColour"];

_markers    = [];
_units      = []; // To clean up units + groups at end
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.

///////////////////////////////////////////////////////////
// Choose Army
///////////////////////////////////////////////////////////
_army = selectRandom ["AAF", "CSAT", "AAF", "CSAT Pacific"];

_army call {
	if (_this isEqualto "CSAT") exitwith {
		_officerClass = "O_Officer_F";
		_side = east;
		_MarkerColour = "colorOPFOR";
        [_officerClass, _side, _MarkerColour];
	};

	if (_this isEqualto "AAF") exitwith {
		_officerClass = "I_Officer_F";
		_side = resistance;
		_MarkerColour = "ColorGUER";
        [_officerClass, _side, _MarkerColour];
	};

	if (_this isEqualto "CSAT Pacific") exitwith {
		_officerClass = "O_T_Officer_F";
		_side = east;
		_MarkerColour = "colorOPFOR";
        [_officerClass, _side, _MarkerColour];
	};
} params ["_officerClass", "_side", "_MarkerColour"];

///////////////////////////////////////////////////////////
// Location Scout
///////////////////////////////////////////////////////////

private ["_pos", "_AOPosition", "_HQPosition", "_loc"];
private _AOSize = 600;

_pos = [_AOSize, "LAND", "FLAT"] call YFNC(AOPos);

_AOPosition = _pos select 0;

_HQPosition = _pos select 1;

_loc = _pos select 2;

// Mission Description
private _missionDescription = format["Main AO at %1", _loc];

///////////////////////////////////////////////////////////
// Spawn Mission
///////////////////////////////////////////////////////////

private ["_hqFunc", "_officerGroup", "_HQElements", "_officerPos", "_officer", "_officerBuilding", "_officerBuildingPositions"];

// Now we have our HQ + Location, bring in the HQ
_missionID = call FNC(getMissionID);

// Get our random HQ Spawn Function
_hqFunc = missionNamespace getVariable (selectRandom ( ["YAINA_SPAWNS_fnc", ["YAINA_SPAWNS", "HQ"]] call YFNC(getFunctions) ));

// Hide any terrain and slam down the HQ
private _hiddenTerrainKey = format["HT_%1", _missionID];
[clientOwner, _hiddenTerrainKey, _HQPosition, 30] remoteExec [QYFNC(hideTerrainObjects), 2];

// Wait for the server to send us back
waitUntil { !isNil {  missionNamespace getVariable _hiddenTerrainKey } };

_HQElements = [_HQPosition, random 360, call _hqFunc] call BIS_fnc_ObjectsMapper;
_buildings  = _HQElements;

// Bring in an officer to one of the buildings
_officerPos = _HQPosition call {
    ([_this, 30] call FNC(findLargestBuilding)) params ["_officerBuilding", "_officerBuildingPositions"];

    if (isNil "_officerBuildingPositions") then {
        // If we didn't find a building revert back to the HQ position
        ["No officer building position found", "ErrorLog"] call YFNC(log);
        _this;
    } else {
        selectRandom _officerBuildingPositions;
    };
};

// Spawn Officer
_officerGroup = createGroup _side;
_officerGroup setGroupIdGlobal [format["mainAO_off_%1", _missionID]];
_officer = _officerGroup createUnit [_officerClass, _officerPos, [],0,"NONE"];
_officer setPos _officerPos;
_units pushBack _officer;

// Add event handler on that officer so we know who dun it
_officer addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator"];

    _instigatorReal = _instigator;
    if (_instigator isEqualTo objNull) then {
        if (_killer isKindOf "UAV") then {
            _instigatorReal = (UAVControl _killer) select 0;
        } else {
            _instigatorReal = _killer;
        };
    };

    parseText format ["<t align='center'><t size='2'>Main Objective</t><br/><t size='1.5' color='#08b000'>PROGRESS</t><br/>____________________<br/><br/>Well done %1! You have killed the Officer stationed in the HQ.<br/><br/>Now, move in on the HQ and defend it from the enemy forces that remain in the area!", [name _instigatorReal, "someone"] select (isNull _instigatorReal)] call YFNC(globalHint);
}];

// Garrison Units around HQ
private _hqg = [_HQPosition, [0,50], _army, 3, nil, _officerPos, 6] call SFNC(infantryGarrison);
_units append _hqg;
[_hqg, format["mainAO_hqg_%1", _missionID]] call FNC(prefixGroups);

// Then the rest of the AO
// mission, center, size, garrisons, inf, inf aa, inf at, snipers, Veh AA, Veh MRAP, Veh Rand, army
([format["mainAO_pa_%1", _missionID], _AOPosition, _AOSize*0.9, _army, [6, 0, _AOSize*0.9, "LRG Default", 6, _HQElements + [_officerPos]], [10,0, "LRG Default"], [2,0, "LRG Default"], [4,0, "LRG Default"], [2,0, "LRG Default"], [2,1], [2,2], [1,2], [0], [0,1]] call SFNC(populateArea)) params ["_spUnits", "_spVehs"];

[str _spUnits] call YFNC(log);
_units append _spUnits;
_vehicles append _spVehs;

// Bring in the Markers
_markers = [_missionID, _AOPosition, _AOSize, nil, nil, nil, _MarkerColour] call FNC(createMapMarkers);

// Add everything to zeus
[ _units + _vehicles] call YFNC(addEditableObjects);

///////////////////////////////////////////////////////////
// Start Mission
///////////////////////////////////////////////////////////

// Set the mission in progress
[
    west,
    _missionID,
    [
        format ["%2 have setup a HQ at %1, you need to clear it out! Good luck and don't forget to complete the side mission we're assigning you.", _loc, _army],
        format ["Clear HQ at %1", _loc],
        ""
    ],
    _AOPosition,
    false,
    0,
    true,
    "Attack",
    true
] call BIS_fnc_taskCreate;

///////////////////////////////////////////////////////////
// Find Side Mission, Needs to be after Main mission start
// so that it becomes a child of it
///////////////////////////////////////////////////////////
private _idx = 5;

_subObjective = nil;

while { _idx > 0 && isNil "_subObjective" } do {
    _k = format["SO_%1", _missionID];
    [_k, _AOPosition, _AOSize, _missionID, _army, _side] call (missionNamespace getVariable (selectRandom ( ["YAINA_MM_OBJ_fnc", ["YAINA_MM_OBJ", "SubObjectives"]] call YFNC(getFunctions) )));
    waitUntil { !isNil { missionNamespace getVariable _k } };
    _mm = missionNamespace getVariable _k;
    if (_mm isEqualTo false) then {
        _idx = _idx - 1;
    } else {
        _subObjective = _mm;
    };
    missionNamespace setVariable [_k, nil];
    _idx = _idx - 1;
};

// Build the progression PFH
_pfh = {

    scopeName "mainPFH";

    params ["_args", "_pfhID"];
    _args params ["_missionID", "_stage", "_subObjective", "_hiddenTerrainKey", "_HQElements", "_officer", "_HQPosition"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && { _stage < 3 }) then {
        // Jump right to stage 3
        _stage = 3;
    };

    if (_stage isEqualTo 1) then {

        if (isNull _officer || { !(alive _officer) } ) then {
            // Whooo officer killed, move to stage 2

            // We create a task, to defend the HQ that's really an extension of this task...
            [
                WEST,
                [format ["%1_defend", _missionID], _missionID],
                [
                    format ["%2 have setup an HQ at %1, you need to clear it out! Good luck and don't forget to complete the side mission we're assigning you.", _loc, _army],
                    "Defend the HQ",
                    ""
                ],
                _HQPosition,
                false,
                0,
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

            [_missionID, 2] call FNC(updateMission);
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

                // Instead of adding a waypoint on the HQ position, we set one between 20-50 meters away, and put them in a
                // smaller patrol pattern

                [_x, [getPos (leader _x), _HQPosition, (20 + random 30)] call YFNC(getPointBetween), 40, 3] call CBA_fnc_taskPatrol;

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
        _alive = { alive _x } count ([_missionID] call FNC(getMissionUnits));

        if (_alive < 20) then {
            // And move on to mission windup, we don't do it here
            // as the PFH resumes until folks are outside the AO
            // and we don't want it to redo this all the time.
            [_missionID, 3] call FNC(updateMission);
            _args set [1,3];
        };
    };

    // Lastly, start our cleanup
    if (_stage isEqualTo 3) then {

        // Complete our dummy task + delete it's marker
        deleteMarker format ["%1_defend_mrk", _missionID];

        // Just delete the task, main task takes care of it
        [format ["%1_defend", _missionID]] call BIS_fnc_deleteTask;

        // Award some points
        if !(_stopRequested) then {
            // Success...
            [3000, "hq research"] call YFNC(addRewardPoints);
            parseText format ["<t align='center' size='2.2'>Main AO</t><br/><t size='1.5' align='center' color='#34DB16'>SUCCESS</t><br/>____________________<br/>Good work out there securing the HQ. You have received %1 credits to compensate your efforts!", 3000] call YFNC(globalHint);
        };

        // Set Mission Exit State
        [_missionID, 'Succeeded', not _stopRequested] call BIS_fnc_taskSetState;

        _args set [1,4];
        _stage = 4;

        [_missionID, _stage, "CLEANUP"] call FNC(updateMission);
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
[_missionID, "AO", 1, _missionDescription, "", _markers, _units, _vehicles, _buildings, _pfh, 10, [_missionID, 1, _subObjective, _hiddenTerrainKey, _HQElements, _officer, _HQPosition]] call FNC(startMissionPFH);
