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
    _ObjectPosition = [nil, call FNC(getAOExclusions) + ["water"], {
        { _x distance2D _this < (_AOSize * 2) } count allPlayers isEqualTo 0 && !(_this isFlatEmpty [5,0,0.1,10,0,false] isEqualTo [])
    }] call BIS_fnc_randomPos;
};

// Suitable location for marker
private _AOPosition = [_ObjectPosition, 0, _AOSize/2, 0, 0, 0, 0, [], []] call BIS_fnc_findSafePos;

// Mission ID Gen
_missionID = call FNC(getMissionID);


///////////////////////////////////////////////////////////
// Objective Setup
///////////////////////////////////////////////////////////

private ["_house", "_table", "_laptop"];

_house = "Land_Research_HQ_F" createVehicle _ObjectPosition;
_house setDir random 360;
_buildings pushBack _house;

// table and laptop
_table = "Land_CampingTable_small_F" createVehicle [0,0,0];
_table setPos (getPos _house vectorAdd [0,0,0.6]);
_table setDir (getDir _house + 90);
_vehicles pushBack _table;

_laptop = (selectRandom ["Land_Laptop_device_F", "Land_Laptop_F"]) createVehicle [0,0,0];
[_table,_laptop,[0,0,0.8]] call BIS_fnc_relPosObject;
_vehicles pushBack _laptop;

_v = (selectRandom ["O_MRAP_02_F","O_Truck_03_covered_F","O_Truck_03_transport_F","O_Heli_Light_02_unarmed_F","O_Truck_02_transport_F","O_Truck_02_covered_F","C_SUV_01_F","C_Van_01_transport_F"]) createVehicle ([_ObjectPosition, 15, 30, 10, 0, 0.5, 0] call BIS_fnc_findSafePos);
_v lock 3;
_vehicles pushBack _v;

// As the above are all destroyable, create a NS
_ns = [true] call CBAP_fnc_createNamespace;

//-------------------- SPAWN FORCE PROTECTION

([_missionID, _ObjectPosition, _AOSize/2, 2, 75] call SFNC(populateArea)) params ["_spGroups", "_spVehs"];

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
        "OPFOR are conducting advanced military research on Altis.Find the data and then torch the place!",
        "Side Mission: Seize Research Data",
        ""
    ],
    _AOPosition,
    false,
    0,
    true,
    "download",
    true
] call BIS_fnc_taskCreate;

// Add Action to plant the explosives...
// We create an empty vehicle at the origin to act as our namespace

[_laptop, "<t color='#ff1111'>Take Laptop and Set Explosives</t>", {
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
        [[west, "HQ"], "Research data secured. The charge is planted! 30 seconds until detonation."] remoteExec ["sideChat"];

        // Delete the laptop, and place explosives down
        deleteVehicle _target;

        // Schedule blow up on server for DC protection
        [30, getPos _target vectorAdd [0,1,0.5], [6,3]] remoteExec [QFNC(destroy), 2];

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
    _args params ["_missionID", "_stage", "_ns", "_house", "_laptop"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && {_stage < 2}) then { _stage = 2; };

    // Main
    if (_stage isEqualTo 1) then {
        if(!alive _house || {!alive _laptop} ) then {

            _mState = "Succeeded";

            // Is tower dead cos it blew up? if so success, else death
            if (_ns getVariable [QVAR(explosivesPlanted), false]) then {
                // Success...
                [500, "hq research"] call YFNC(addRewardPoints);
                parseText format ["<t align='center' size='2.2'>Side Mission</t><br/><t size='1.5' align='center' color='#34DB16'>Research Data</t><br/>____________________<br/>Good work out there. You have received %1 credits to compensate your efforts!", 500] call YFNC(globalHint);
            } else {
                // Failed...
                _mState = "Failed";
                [-500, "secure radar"] call YFNC(addRewardPoints);
                parseText format ["<t align='center'><t size='2.2'>Side Mission</t><br/><t size='1.5' color='#FF0808'>FAILED</t><br/>____________________<br/> Mission Failed! The Research Data was destroyed! We've just lost %1 credits as a result. Secure the laptop nest time.</t>",500] call YFNC(globalHint);
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
        // Initiate default cleanup function to clean up officer group + group
        if ([_pfhID, _missionID, _stopRequested] call FNC(missionCleanup)) then {
            deleteVehicle _ns;
        };
    };
};

// Enable players to drop onto this mission
[(_markers select 0)] call FNC(setupParadrop);

// For now just start it
[_missionID, "SM", 1, "secure intel (vehicle)", "", _markers, _groups, _vehicles, _buildings, _pfh, 3, [_missionID, 1, _ns, _house, _laptop]] call FNC(startMissionPFH);
