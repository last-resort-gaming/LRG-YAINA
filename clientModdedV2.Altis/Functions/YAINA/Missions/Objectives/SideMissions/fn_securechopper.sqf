/*
Function: YAINA_MM_OBJ_fnc_securechopper

Description:
	Find and destroy an enemy helicopter before it gets a chance to escape.
    Randomly selects one of the following factions for populating the mission:

    AAF, CSAT, CSAT Pacific

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
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings", "_side", "_MarkerColour", "_RandomHeli"];

_markers    = [];
_units      = []; // To clean up units + groups at end
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.

_army = selectRandom ["CSAT","AAF","CSAT Pacific"];

_army call {
    if (_this isEqualTo "CSAT") exitwith {
		_side = east;
		_MarkerColour = "colorOPFOR";
		_RandomHeli = ["O_Heli_Attack_02_black_F","O_Heli_Light_02_unarmed_F","O_Heli_Attack_02_dynamicLoadout_F"];
        [_side, _MarkerColour, _RandomHeli];
    };
    if (_this isEqualTo "AAF") exitwith {
		_side = resistance;
		_MarkerColour = "ColorGUER";
		_RandomHeli = ["I_Heli_light_03_dynamicLoadout_F","I_Heli_light_03_unarmed_F","I_Heli_Transport_02_F"];
        [_side, _MarkerColour, _RandomHeli];
    };
    if (_this isEqualTo "CSAT Pacific") exitwith {
		_side = east;
		_MarkerColour = "colorOPFOR";
		_RandomHeli = ["O_Heli_Attack_02_black_F","O_Heli_Light_02_unarmed_F","O_Heli_Attack_02_dynamicLoadout_F"];
        [_side, _MarkerColour, _RandomHeli];
    };
} params ["_side", "_MarkerColour", "_RandomHeli"];

///////////////////////////////////////////////////////////
// AO Setup
///////////////////////////////////////////////////////////

private _AOSize = 400;
private _ObjectPosition = [0,0];

private _pos = [_AOSize, "LAND", "FLAT"] call YFNC(AOPos);

_ObjectPosition = _pos select 0;

// Suitable location for marker
private _AOPosition = _pos select 1;

// Mission ID Gen
_missionID = call FNC(getMissionID);


///////////////////////////////////////////////////////////
// Objective Setup
///////////////////////////////////////////////////////////

// plop down the hangar for now
private _hangar = createVehicle ["Land_TentHangar_V1_F", [0,0,0], [], 0, "NONE"];
private _d = [];
{
    if (typeName _x != "ARRAY") then {
        [format ["Invalid bounding box: %1, source building: %2", _x, _hangar], "ErrorLog"] call YFNC(log);
    };
    _d append ((_x select [0,2]) apply { abs _x } );
    true;
} count (boundingBox _hangar);

// Hide any terrain and slam down the hangar
private _hiddenTerrainKey = format["HT_%1", _missionID];
[clientOwner, _hiddenTerrainKey, _ObjectPosition, (selectMax _d) + 2] remoteExec [QYFNC(hideTerrainObjects), 2];

// Wait for the server to send us back
waitUntil { !isNil {  missionNamespace getVariable _hiddenTerrainKey } };


// Then re-position
_hangar setPos _ObjectPosition;
_hangar setDir (random 360);

private _surfaceNormal = surfaceNormal position _hangar;
_hangar setVectorUp _surfaceNormal;
_buildings pushBack _hangar;

// Spawn Chopper
private _chopper = createVehicle [selectRandom _RandomHeli, [0,0,0], [], 0, "NONE"];
_chopper setDir (getDir _hangar);
_chopper setVectorUp _surfaceNormal;
_chopper setPosATL (getPosATL _hangar);
_chopper lock 3;
_vehicles pushBack _chopper;

// House with Laptop
_house = "Land_Cargo_House_V3_F" createVehicle ([_ObjectPosition, 15, 30, 10, 0, 0.5, 0] call BIS_fnc_findSafePos);
_house setDir random 360;
_house allowDamage false;
_buildings pushBack _house;

// table and laptop
_table = "Land_CampingTable_small_F" createVehicle [0,0,0];
_table setPos (getPos _house vectorAdd [0,0,0.6]);
_table setDir (getDir _house + 90);

_laptop = (selectRandom ["Land_Laptop_device_F", "Land_Laptop_F"]) createVehicle [0,0,0];
[_table,_laptop,[0,0,0.8]] call BIS_fnc_relPosObject;

_vehicles pushBack _table;
_vehicles pushBack _laptop;

// Namespace for variables, something that wont die before cleanup :)
_ns = _house;


//-------------------- SPAWN FORCE PROTECTION

// Garrison Units around HQ
private _hqg = [getPos _house, [0,30], _army] call SFNC(infantryGarrison);
_units append _hqg;
[_hqg, format["securechopper_gar_%1", _missionID]] call FNC(prefixGroups);

// Then the rest of the AO
([format["securechopper_pa_%1", _missionID], _ObjectPosition, _AOSize/2, _army, [2, 30, 75]] call SFNC(populateArea)) params ["_spUnits", "_spVehs"];

// Bring in the Markers
_markers = [_missionID, _AOPosition, _AOSize, nil, nil, nil, _MarkerColour] call FNC(createMapMarkers);

// Add to Zeus
_vehicles append _spVehs;
_units append _spUnits;

// Add everything to zeus
[ _units + _vehicles + _buildings, false] call YFNC(addEditableObjects);

// Set the mission in progress
[
    west,
    _missionID,
    [
        "OPFOR forces have been provided with a new prototype attack chopper and they're keeping it in a hangar somewhere on the island.We've marked the suspected location on your map; head to the hangar, get the data and destroy the helicopter.",
        "Side Mission: Secure Chopper",
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

[_laptop, {}, "<t color='#ff1111'>Take Laptop and Set Explosives</t>", {
    params ["_target", "_caller", "_id", "_arguments"];
    _arguments params ["_objective", "_ns"];

    // We set serverTime to now, in case of a DC whilst downloading, we
    // dont want the mission to bug out, also limits two folks planting
    _target setVariable[QVAR(explosivesPlanting), serverTime, true];

    // Side message telling folks who's doing it
    [[west, "HQ"], format ["%1 is planting the explosives!",name player]] remoteExec ["sideChat"];

    ["Planting Explosives", 10, {
        // Success, move onto verify
        params ["_target", "_objective", "_ns"];

        // We set complete on _ns as our laptop is about to be deleted and we need
        // to know if it was destoryed by friendlies or by the explosion
        _ns setVariable [QVAR(explosivesPlanted), true, true];

        // Let them know detonation in 30 seconds
        [[west, "HQ"], selectRandom [
            "Chopper data secured. The charge has been set! 30 seconds until detonation.",
            "Heli data secured. The explosives have been set! 30 seconds until detonation.",
            "Chopper intel secured. The charge is planted! 30 seconds until detonation."]] remoteExec ["sideChat"];


        // Delete the laptop, and place explosives down
        deleteVehicle _target;

        // We place the explosives down, and delete the laptop
        _ap = getPos _objective vectorAdd [0,1,0.5];
        _ammo = "Box_NATO_AmmoOrd_F" createVehicle _ap;

        // Schedule blow up on server for DC protection
        [30, _ap] remoteExec [QFNC(destroy), 2];

    }, [_target, _objective, _ns], {
        // on Abort;
        params ["_target", "_objective", "_ns"];
        _target setVariable[QVAR(explosivesPlanting), 0, true];
        [[west, "HQ"], format["%1 failed to set the explosives, we need to try again!", name player]] remoteExec ["sideChat"];
    }] call AIS_Core_fnc_Progress_ShowBar;

}, [_chopper, _ns], 6, false, true, "", format["alive _target && { (serverTime - (_target getVariable['%1', 0])) > 12 }", QVAR(explosivesPlanting)], 5, false] call YFNC(addActionMP);

// Now onto the easier completion PFH
_pfh = {
    scopeName "mainPFH";

    params ["_args", "_pfhID"];
    _args params ["_missionID", "_stage", "_hiddenTerrainKey", "_ns", "_chopper", "_laptop"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && {_stage < 2}) then { _stage = 2; };

    // Main
    if (_stage isEqualTo 1) then {
        if(!alive _chopper || {!alive _laptop} ) then {

            _mState = "Succeeded";

            // Is tower dead cos it blew up? if so success, else death
            if (_ns getVariable [QVAR(explosivesPlanted), false]) then {
                // Success...
                [500, "secure radar"] call YFNC(addRewardPoints);
                parseText format ["<t align='center' size='2.2'>Side Mission</t><br/><t size='1.5' align='center' color='#34DB16'>Secure Chopper</t><br/>____________________<br/>Good work out there. You have received %1 credits to compensate your efforts!", 500] call YFNC(globalHint);
            } else {
                // Failed...
                _mState = "Failed";
                [-500, "secure radar"] call YFNC(addRewardPoints);
                parseText format ["<t align='center'><t size='2.2'>Side Mission</t><br/><t size='1.5' color='#FF0808'>FAILED</t><br/>____________________<br/> Mission Failed! The Intel was destroyed! We've just lost %1 credits as a result. Secure the laptop nest time.</t>",500] call YFNC(globalHint);
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
        if ([_pfhID, _missionID, _stopRequested] call FNC(missionCleanup)) then {
            [_hiddenTerrainKey] remoteExec [QYFNC(showTerrainObjects), 2];
        };
    };
};

// Enable players to drop onto this mission
[(_markers select 0)] call FNC(setupParadrop);

// For now just start it
[_missionID, "SM", 1, "secure chopper", "", _markers, _units, _vehicles, _buildings, _pfh, 3, [_missionID, 1, _hiddenTerrainKey, _ns, _chopper, _laptop]] call FNC(startMissionPFH);
