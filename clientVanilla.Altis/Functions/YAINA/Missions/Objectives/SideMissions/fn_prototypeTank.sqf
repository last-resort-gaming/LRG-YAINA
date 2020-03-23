/*
Function: YAINA_MM_OBJ_fnc_protoypeTank

Description:
	Destroy a prototype tank before the enemy gets a chance to use it on you.
    Randomly selects one of the following armies for populating the mission:

    AAF, CSAT, CSAT Pacific

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	BACONMOP - Original Mission
    Martin - Ported to YAINA
    MitchJC - Random Faction Selection
*/

#include "..\..\defines.h"

// We always start with these 6, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings", "_side", "_MarkerColour", "_tanktype", "_Textures"];

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
		_tanktype = "O_MBT_04_command_F";
		_Textures = [
			[0, "a3\Armor_F_Tank\MBT_04\Data\MBT_04_exterior_1_CO.paa"],
			[1, "a3\Armor_F_Tank\MBT_04\Data\MBT_04_exterior_2_CO.paa"],
			[2, "A3\Armor_F\Data\camonet_CSAT_Stripe_desert_CO.paa"]
		];
        [_side, _MarkerColour, _tanktype, _Textures];
    };
    if (_this isEqualTo "AAF") exitwith {
		_side = resistance;
		_MarkerColour = "ColorGUER";
		_tanktype = "I_MBT_03_cannon_F";
		_Textures = [
			[0, "a3\armor_f_epb\mbt_03\data\mbt_03_ext01_co.paa"],
			[1, "a3\armor_f_epb\mbt_03\data\mbt_03_ext02_co.paa"],
			[2, "a3\armor_f_epb\mbt_03\data\mbt_03_rcws_co.paa"],
			[3, "A3\Armor_F\Data\camonet_AAF_Digi_Green_CO.paa"]
		];
        [_side, _MarkerColour, _tanktype, _Textures];
    };
    if (_this isEqualTo "CSAT Pacific") exitwith {
		_side = east;
		_MarkerColour = "colorOPFOR";
        _tanktype = "O_T_MBT_04_command_F";
		_Textures = [
			[0, "a3\Armor_F_Tank\MBT_04\Data\MBT_04_exterior_1_CO.paa"],
			[1, "a3\Armor_F_Tank\MBT_04\Data\MBT_04_exterior_2_CO.paa"],
			[2, "A3\Armor_F\Data\camonet_CSAT_Stripe_desert_CO.paa"]
		];
        [_side, _MarkerColour, _tanktype, _Textures];
    };
} params ["_side", "_MarkerColour", "_tanktype", "_Textures"];

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
// Spwan Tank
///////////////////////////////////////////////////////////

private _grp1 = createGroup _side;
private _protoTank = createVehicle [_tanktype, _ObjectPosition,[],0,"NONE"];
[_protoTank,_grp1] call BIS_fnc_spawnCrew;



_protoTank animate ["showCamonetHull",1];
_protoTank animate ["showCamonetTurret",1];
{_protoTank setObjectTexture _x;} forEach _textures;
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
    _damage = _olddamage + ((_this select 2) - _olddamage) * 0.75;
    _gethit set [_i, _damage];
    _unit setVariable ["gethit", _gethit];
    _damage;
}];

[_grp1, _ObjectPosition, 200] call bis_fnc_taskPatrol;

_vehicles pushBack _protoTank;
_units append (units _grp1);

// Spawn SM Forces --------------------------------

// Whilst majority independents
([format["prototypeTank_pa1_%1", _missionID], _ObjectPosition,300, _army, [0], [4], [2], [2], [0], [2], [3], [1,1]] call SFNC(populateArea)) params ["_smUnits", "_smVehs"];
_units append _smUnits;
_vehicles append _smVehs;

///////////////////////////////////////////////////////////
// Start Mission
///////////////////////////////////////////////////////////

// Bring in the Markers
_markers = [_missionID, _AOPosition, _AOSize, nil, nil, nil, _MarkerColour] call FNC(createMapMarkers);

// Add everything to zeus
[ _units + _vehicles, false] call YFNC(addEditableObjects);

// Set the mission in progress
[
    west,
    _missionID,
    [
        "We have gotten reports that hostile forces have sent a prototype tank to their allies for a field test. Get over there and destroy that thing. Be careful, our operatives have said that has much more armor than standard and carries a wide array of powerful weapons.",
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