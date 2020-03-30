/*
Function: YAINA_MM_OBJ_fnc_hqcoast

Description:
    Find and destroy smuggled explosives stored at an enemy HQ.
    Randomly selects one of the following armies for populating the mission:

    AAF, CSAT, CSAT Pacific, Syndikat

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

// We always start with these 6, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings","_side", "_Boat", "_BoatCrew","_MarkerColour"];

_markers    = [];
_units     = []; // To clean up units + groups at end
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.

_army = selectRandom ["CSAT","AAF","CSAT Pacific","Syndikat"];

_army call {
    if (_this isEqualTo "CSAT") exitwith {
		_side = east;
		_MarkerColour = "colorOPFOR";
		_Boat = "O_Boat_Armed_01_hmg_F";
		_BoatCrew = "O_Soldier_F";
        [_side, _MarkerColour, _Boat, _BoatCrew];
    };
    if (_this isEqualTo "AAF") exitwith {
		_side = resistance;
		_MarkerColour = "ColorGUER";
		_Boat = "I_Boat_Armed_01_minigun_F";
		_BoatCrew = "I_Soldier_F";
        [_side, _MarkerColour, _Boat, _BoatCrew];
    };
    if (_this isEqualTo "CSAT Pacific") exitwith {
		_side = east;
		_MarkerColour = "colorOPFOR";
		_Boat = "O_T_Boat_Armed_01_hmg_F";
		_BoatCrew = "O_T_Soldier_F";
        [_side, _MarkerColour, _Boat, _BoatCrew];
    };
    if (_this isEqualTo "Syndikat") exitwith {
		_side = resistance;
		_MarkerColour = "ColorGUER";
		_Boat = "I_Boat_Armed_01_minigun_F";
		_BoatCrew = "I_C_Soldier_Para_1_F";
        [_side, _MarkerColour, _Boat, _BoatCrew];
    };
} params ["_side", "_MarkerColour", "_Boat", "_BoatCrew"];
///////////////////////////////////////////////////////////
// AO Setup
///////////////////////////////////////////////////////////

private _AOSize = 400;
private _ObjectPosition = [0,0];

private _pos = [_AOSize, "LAND", "COAST"] call YFNC(AOPos);

_ObjectPosition = _pos select 0;

// Suitable location for marker
private _AOPosition = _pos select 1;

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
_g = createGroup _side;
_g setGroupIdGlobal [format["hqcoast_bg_%1", _missionID]];

_p = [_ObjectPosition, 50, 150, 10, 2, 1, 0] call BIS_fnc_findSafePos;
_v = _boat createVehicle _p;
_v setDir (random 360);
_vehicles pushBack _v;

_u = _g createUnit [_BoatCrew, _p, [], 0, "NONE"]; _u assignAsCommander _v; _u moveInCommander _v;
_u = _g createUnit [_BoatCrew, _p, [], 0, "NONE"]; _u assignAsDriver _v; _u moveInDriver _v;
_u = _g createUnit [_BoatCrew, _p, [], 0, "NONE"]; _u assignAsGunner _v; _u moveInGunner _v;
_u = _g createUnit [_BoatCrew, _p, [], 0, "NONE"]; _u assignAsCargo _v; _u moveInCargo _v;
_u = _g createUnit [_BoatCrew, _p, [], 0, "NONE"]; _u assignAsCargo _v; _u moveInCargo _v;

// Set group skill
[_g, "LRG Default"] call SFNC(setUnitSkill);
_units append (units _g);

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
private _hqg = [getPos _hq, [0,30], _army, nil, nil, nil, 6] call SFNC(infantryGarrison);
_units append _hqg;
[_hqg, format["hqcoast_gar_%1", _missionID]] call FNC(prefixGroups);

// Then the rest of the AO
([format["hqcoast_pa_%1", _missionID], _ObjectPosition, _AOSize/2, _army, [2, 30, 75]] call SFNC(populateArea)) params ["_spUnits", "_spVehs"];

// Bring in the Markers
_markers = [_missionID, _AOPosition, _AOSize, nil, nil, nil, _MarkerColour] call FNC(createMapMarkers);

// Add to Zeus
_units append _spUnits;
_vehicles append _spVehs;

// Add everything to zeus
[ _units + _vehicles + _buildings, false] call YFNC(addEditableObjects);

// Set the mission in progress
[
    west,
    _missionID,
    [
        "Forces have been smuggling explosives onto the island and hiding them in a Mobile HQ on the coastline.We've marked the building on your map; head over there and secure the current shipment. Keep well back when you blow it, there's a lot of stuff in that building.",
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

[_crate, {}, "<t color='#ff1111'>Secure Cargo and Set Charge</t>", {
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
        // to know if it was destroyed by friendlies or by the explosion
        _ns setVariable [QVAR(explosivesPlanted), true, true];

        // Let them know detonation in 30 seconds
        [[west, "HQ"], selectRandom [
            "The charge has been set! 30 seconds until detonation.",
            "The c4 has been set! 30 seconds until detonation.",
            "The charge is set! 30 seconds until detonation."]] remoteExec ["sideChat"];

        // Schedule blow up on server for DC protection
        [30, getPos _target vectorAdd [0,1,0.5], [6,4,5]] remoteExec [QFNC(destroy), 2];

    }, [_target, _ns], {
        // on Abort;
        params ["_target", "_ns"];
        _target setVariable[QVAR(explosivesPlanting), 0, true];
        [[west, "HQ"], format["%1 failed to set the explosives, we need to try again!", name player]] remoteExec ["sideChat"];
    }] call AIS_Core_fnc_Progress_ShowBar;

}, [_ns], 6, false, true, "", format["alive _target && { (serverTime - (_target getVariable['%1', 0])) > 12 }", QVAR(explosivesPlanting)], 5, false] call YFNC(addActionMP);

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
                parseText format ["<t align='center' size='2.2'>Side Mission</t><br/><t size='1.5' align='center' color='#34DB16'>Secure Cargo</t><br/>____________________<br/>Good work out there. You have received %1 credits to compensate your efforts!", 500] call YFNC(globalHint);
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
[_missionID, "SM", 1, "secure cargo", "", _markers, _units, _vehicles, _buildings, _pfh, 3, [_missionID, 1, _ns, _hq, _crate]] call FNC(startMissionPFH);
