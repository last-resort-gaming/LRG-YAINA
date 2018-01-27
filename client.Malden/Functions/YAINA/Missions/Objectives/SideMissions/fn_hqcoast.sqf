/*
@file: destroyRadar.sqf
Author:

	Quiksilver

Last modified:

	25/04/2014
    23/01/2018 - MartinCo - rewritten for YAINA
Description:

	Get radar telemetry from enemy radar site, then destroy it.
_________________________________________________________________________*/
#include "..\..\defines.h"

// We always start with these 6, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_groups", "_vehicles", "_buildings"];

_markers    = [];
_groups     = []; // To clean up units + groups at end
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
    // pick a random spawn that's 2 * _AOSize away from players + other AOs
    _ObjectPosition = [nil, ([] call FNC(getAOExclusions)) + ["water"], {
        { _x distance2D _this < (_AOSize * 2) } count allPlayers isEqualTo 0 && !(_this isFlatEmpty [2,-1,0.3,1,1,true] isEqualTo [])
    }] call BIS_fnc_randomPos;
};

// Suitable location for marker
private _AOPosition = [_ObjectPosition, 0, _AOSize/2, 0, 0, 0, 0, [], []] call BIS_fnc_findSafePos;

// Mission ID Gen
_missionID = call FNC(getMissionID);

///////////////////////////////////////////////////////////
// Objective Setup
///////////////////////////////////////////////////////////

private ["_g", "_u", "_v", "_p", "_crate", "_hq"];

_hq = "Land_Cargo_HQ_V1_F" createVehicle _ObjectPosition;
_hq setDir (random 360);
_buildings pushBack _hq;

_crate = (selectRandom ["Box_East_AmmoVeh_F", "Land_CargoBox_V1_F"]) createVehicle [0,0,0];
_crate setPos (getPos _hq vectorAdd [0,0,5]);
_vehicles pushBack _crate;

// Boat
_g = createGroup east;
_g setGroupIdGlobal [format["%1_bg", _missionID]];

_p = [_ObjectPosition, 50, 150, 10, 2, 1, 0] call BIS_fnc_findSafePos;
_v = "O_Boat_Armed_01_hmg_F" createVehicle _p;
_v setDir (random 360);
_vehicles pushBack _v;

_u = _g createUnit ["O_diver_TL_F" , _p, [], 0, "NONE"]; _u assignAsCommander _v; _u moveInCommander _v;
_u = _g createUnit ["O_diver_F", _p, [], 0, "NONE"]; _u assignAsDriver _v; _u moveInDriver _v;
_u = _g createUnit ["O_diver_F", _p, [], 0, "NONE"]; _u assignAsGunner _v; _u moveInGunner _v;
_u = _g createUnit ["O_diver_F", _p, [], 0, "NONE"]; _u assignAsCargo _v; _u moveInCargo _v;
_u = _g createUnit ["O_diver_F", _p, [], 0, "NONE"]; _u assignAsCargo _v; _u moveInCargo _v;

// Set group skill
[_g, 2] call SFNC(setUnitSkill);
_groups pushBack _g;

//---------- SHIPPING TRAWLER AND INFLATABLE BOAT FOR AMBIENCE

_v = "C_Boat_Civil_04_F" createVehicle ([_ObjectPosition, 200, 300, 10, 2, 1, 0] call BIS_fnc_findSafePos);
_v setDir random 360;
_v allowDamage false;
_v lock 3;
_vehicles pushBack _v;

_v = "O_Boat_Transport_01_F" createVehicle ([_ObjectPosition, 15, 25, 10, 0, 1, 0] call BIS_fnc_findSafePos);
_v setDir random 360;
_v allowDamage false;
_v lock 3;
_vehicles pushBack _v;

// Namespace for variables, something that wont die before cleanup :)
_ns = _v;

//-------------------- SPAWN FORCE PROTECTION

// Garrison Units around HQ
private _hqg = [getPos _hq, [0,30], nil, nil, nil, 6] call SFNC(infantryGarrison);
{ _groups pushBack _x; _x setGroupIdGlobal [format["%1_hqg%2", _missionID, _forEachIndex]]; } forEach _hqg;

// Then the rest of the AO
([_missionID, _ObjectPosition, _AOSize/2, 2, [30, 75]] call SFNC(populateArea)) params ["_spGroups", "_spVehs"];


// Bring in the Markers
_markers = [_missionID, _AOPosition, _AOSize] call FNC(createMapMarkers);

// Add to Zeus
_vehicles = _vehicles + _spVehs;
_groups = _spGroups;

// Add everything to zeus
{ [units _x] call YFNC(addEditableObjects); true; } count _groups;
[ _vehicles + _buildings, true] call YFNC(addEditableObjects);

// Set the mission in progress
[
    west,
    _missionID,
    [
        "OPFOR have been smuggling explosives onto the island and hiding them in a Mobile HQ on the coastline.We've marked the building on your map; head over there and secure the current shipment. Keep well back when you blow it, there's a lot of stuff in that building.",
        "Side Mission: Secure Smuggled Explosives",
        ""
    ],
    _AOPosition,
    false,
    0,
    true,
    "destroy",
    true
] call BIS_fnc_taskCreate;

// Add Action to plant the explosives...
// We create an empty vehicle at the origin to act as our namespace

[_crate, "<t color='#ff1111'>Secure Cargo and Set Charge</t>", {
    params ["_target", "_caller", "_id", "_arguments"];
    _arguments params ["_ns"];

    // We set serverTime to now, in case of a DC whilst downloading, we
    // dont want the mission to bug out, also limits two folks planting
    _target setVariable[QVAR(explosivesPlanting), serverTime, true];

    // Side message telling folks who's doing it
    [[west, "HQ"], format ["%1 is planting the explosives!",name player]] remoteExec ["sideChat"];

    ["Planting Explosives", 10, {
        // Success, move onto verify
        params ["_target", "_ns"];

        // We set complete on _ns as our laptop is about to be deleted and we need
        // to know if it was destoryed by friendlies or by the explosion
        _ns setVariable [QVAR(explosivesPlanted), true, true];

        // Let them know detonation in 30 seconds
        [[west, "HQ"], selectRandom [
            "The charge has been set! 30 seconds until detonation.",
            "The c4 has been set! 30 seconds until detonation.",
            "The charge is set! 30 seconds until detonation."]] remoteExec ["sideChat"];

        // Schedule blow up on server for DC protection
        [30, getPos _target vectorAdd [0,1,0.5], [6,5]] remoteExec [QFNC(destroy), 2];

    }, [_target, _ns], {
        // on Abort;
        params ["_target", "_ns"];
        _target setVariable[QVAR(explosivesPlanting), 0, true];
        [[west, "HQ"], format["%1 failed to set the explosives, we need to try again!", name player]] remoteExec ["sideChat"];
    }] call AIS_Core_fnc_Progress_ShowBar;

}, [_ns], 6, false, true, "", format["alive _target && { serverTime - (_target getVariable['%1', 0]) > 12 } }", QVAR(explosivesPlanting)], 5, false] call YFNC(addActionMP);

// Now onto the easier completion PFH
_pfh = {
    scopeName "mainPFH";

    params ["_args", "_pfhID"];
    _args params ["_missionID", "_stage", "_ns", "_hq", "_crate"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && {_stage < 2}) then { _stage = 2; };

    // Main
    if (_stage isEqualTo 1) then {
        if(!alive _hq || {!alive _crate} ) then {

            _mState = "Succeeded";

            // Is tower dead cos it blew up? if so success, else death
            if (_ns getVariable [QVAR(explosivesPlanted), false]) then {
                // Success...
                [500, "hq coast"] call YFNC(addRewardPoints);
                parseText format ["<t align='center' size='2.2'>Side Mission</t><br/><t size='1.5' align='center' color='#34DB16'>Secure Radar</t><br/>____________________<br/>Good work out there. You have received %1 credits to compensate your efforts!", 500] call YFNC(globalHint);
            } else {
                // Failed...
                _mState = "Failed";
                [-500, "hq coast"] call YFNC(addRewardPoints);
                parseText format ["<t align='center'><t size='2.2'>Side Mission</t><br/><t size='1.5' color='#FF0808'>FAILED</t><br/>____________________<br/> Mission Failed! You failed to secure the cargo as it was destroyed! We've just lost %1 credits as a result. You must secure it nest time.</t>",500] call YFNC(globalHint);
            };

            [_missionID, _mState, true] call BIS_fnc_taskSetState;

            _stage = 2; _args set [1, _stage];
            [_missionID, _stage, "CLEANUP"] call FNC(updateMission);
        };
    };

    if (_stage isEqualTo 2) then {
        if (_stopRequested) then {
            [_missionID, "Succeeded", false] call BIS_fnc_taskSetState;
        };

        _stage = 3; _args set [1, _stage];
    };

    if (_stage isEqualTo 3) then {
        [_pfhID, _missionID, _stopRequested] call FNC(missionCleanup);
    };
};

// Enable players to drop onto this mission
[(_markers select 0)] call FNC(setupParadrop);

// For now just start it
[_missionID, "SM", 1, "secure intel (vehicle)", "", _markers, _groups, _vehicles, _buildings, _pfh, 3, [_missionID, 1, _ns, _hq, _crate]] call FNC(startMissionPFH);
