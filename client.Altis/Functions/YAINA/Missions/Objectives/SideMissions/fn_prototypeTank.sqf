/*
Author: BACONMOP, Ported to YAINA by MartinCo
Destroy a prototype Tank
*/

#include "..\..\defines.h"

// We always start with these 6, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings"];

_markers    = [];
_units      = []; // To clean up units + groups at end
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.


///////////////////////////////////////////////////////////
// AO Setup
///////////////////////////////////////////////////////////

private _AOSize = 400;
private _ObjectPosition = [0,0];

while { _ObjectPosition isEqualTo [0,0] } do {
    _ObjectPosition = [nil, ([_AOSize] call FNC(getAOExclusions)) + ["water"], {
        { _x distance2D _this < (_AOSize * 2) } count allPlayers isEqualTo 0 && !(_this isFlatEmpty [-1,-1,0.7,10,0,false,objNull] isEqualTo [])
    }] call BIS_fnc_randomPos;
};

private _AOPosition = [_ObjectPosition, 0, 100, 0, 0, 0, 0, [], []] call BIS_fnc_findSafePos;

// Mission ID Gen
_missionID = call FNC(getMissionID);

///////////////////////////////////////////////////////////
// Spwan Tank
///////////////////////////////////////////////////////////

private _grp1 = createGroup east;
private _protoTank = createVehicle ["O_MBT_02_cannon_F", _ObjectPosition,[],0,"NONE"];
[_protoTank,_grp1] call BIS_fnc_spawnCrew;

_protoTank removeWeapon ("cannon_125mm");
_protoTank removeWeapon ("LMG_coax");
_protoTank removeMagazine "24Rnd_125mm_APFSDS_T_Green";
_protoTank removeMagazine "12Rnd_125mm_HE_T_Green";
_protoTank removeMagazine "12Rnd_125mm_HEAT_T_Green";
_protoTank addWeapon ("rockets_230mm_GAT");
_protoTank addMagazine "12Rnd_230mm_rockets";
_protoTank addMagazine "12Rnd_230mm_rockets";
_protoTank addMagazine "12Rnd_230mm_rockets";
_protoTank addWeapon ("Gatling_30mm_Plane_CAS_01_F");
_protoTank addMagazine "1000Rnd_Gatling_30mm_Plane_CAS_01_F";
_protoTank addMagazine "1000Rnd_Gatling_30mm_Plane_CAS_01_F";
_protoTank addWeapon ("Missile_AGM_02_Plane_CAS_01_F");
_protoTank addMagazine "6Rnd_Missile_AGM_02_F";
_protoTank addWeapon ("Rocket_04_HE_Plane_CAS_01_F");
_protoTank addMagazine "7Rnd_Rocket_04_HE_F";
_protoTank addMagazine "7Rnd_Rocket_04_HE_F";
_protoTank addMagazine "7Rnd_Rocket_04_HE_F";

_protoTank lock 3;
_protoTank allowCrewInImmobile true;

_protoTank setVariable ["selections", []];
_protoTank setVariable ["gethit", []];

// Limit the damage taken by the tank
_protoTank addEventHandler ["HandleDamage", {
    _unit = _this select 0;
    _selections = _unit getVariable ["selections", []];
    _gethit = _unit getVariable ["gethit", []];
    _selection = _this select 1;
    if !(_selection in _selections) then
    {
        _selections set [count _selections, _selection];
        _gethit set [count _gethit, 0];
    };
    _i = _selections find _selection;
    _olddamage = _gethit select _i;
    _damage = _olddamage + ((_this select 2) - _olddamage) * 0.25;
    _gethit set [_i, _damage];
    _damage;
}];

[_grp1, _ObjectPosition, 200] call bis_fnc_taskPatrol;

_vehicles pushBack _protoTank;
_units append (units _grp1);

// Spawn SM Forces --------------------------------

// Whilst marjoity indipendants
([format["prototypeTank_pa1_%1", _missionID], _ObjectPosition,300, resistance, [0], [4], [0], [0], [0], [2], [3], [1,1]] call SFNC(populateArea)) params ["_smUnits", "_smVehs"];
_units append _smUnits;
_vehicles append _smVehs;

// We want some AA/AT Teams so add in some easties
([format["prototypeTank_pa2_%1", _missionID], _ObjectPosition,300, east, [0], [0], [2], [2], [0], [0], [0], [0], [0], [0]] call SFNC(populateArea)) params ["_smUnits", "_smVehs"];
_units append _smUnits;
_vehicles append _smVehs;


///////////////////////////////////////////////////////////
// Start Mission
///////////////////////////////////////////////////////////

// Bring in the Markers
_markers = [_missionID, _AOPosition, _AOSize] call FNC(createMapMarkers);

// Add everything to zeus
[ _units + _vehicles, false] call YFNC(addEditableObjects);

// Set the mission in progress
[
    west,
    _missionID,
    [
        "We have gotten reports that OpFor have sent a prototype tank to their allies for a field test. Get over there and destroy that thing. Be careful, our operatives have said that has much more armor than standard and carries a wide array of powerful weapons.",
        "Side Mission: Prototype Tank",
        ""
    ],
    _AOPosition,
    false,
    0,
    true,
    "destroy",
    true
] call BIS_fnc_taskCreate;

// Build the progression PFH
_pfh = {
    scopeName "mainPFH";

    params ["_args", "_pfhID"];
    _args params ["_missionID", "_stage", "_protoTank"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && {_stage < 3}) then { _stage = 2; };


    // Now make sure the prototype tank is dead
    if (_stage isEqualTo 1 && { not _stopRequested }) then {
        if (!alive _protoTank) then {
            // Move onto stage 2, cleanup
            _stage = 2; _args set [1,_stage];
        };
    };

    // We have stage 2 just to set the params to avoid executing it each time whilst waiting for cleanup
    if (_stage isEqualTo 2) then {

        // Give them some points
        if !(_stopRequested) then {
            [500, "protoType tank"] call YFNC(addRewardPoints);
            parseText format ["<t align='center' size='2.2'>Side Mission</t><br/><t size='1.5' align='center' color='#34DB16'>Prototype Tank</t><br/>____________________<br/>Good work out there. You have received %1 credits to compensate your efforts!", 500] call YFNC(globalHint);
        };

        _stage = 3; _args set [1,_stage];

        [_missionID, 'Succeeded', not _stopRequested] call BIS_fnc_taskSetState;
        [_missionID, _stage, "CLEANUP"] call FNC(updateMission);

    };

    if (_stage isEqualTo 3) then {
        [_pfhID, _missionID, _stopRequested] call FNC(missionCleanup);
    };
};


// Enable players to drop onto this mission
[(_markers select 0)] call FNC(setupParadrop);

// For now just start it
[_missionID, "SM", 1, "prototype tank", "", _markers, _units, _vehicles, _buildings, _pfh, 5, [_missionID, 1, _protoTank]] call FNC(startMissionPFH);