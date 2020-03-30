/*
Function: YAINA_MM_OBJ_fnc_aa

Description:
	Priority Target: AA. The Anti-Air installation engages all BLUFOR aircrafts
    and takes them down (most of the time).
    Randomly selects one of the following armies for the mission (inherited from Main AO):

    AAF, CSAT, CSAT Pacific

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Quiksilver - Original Mission Idea
    Rarek [AW] - Adapted and updated
    Martin - Ported to YAINA
    MitchJC - Random Faction Selection
*/

#include "..\..\defines.h"

// We always start with these 6, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings", "_AA1", "_AA2", "_AA3", "_v", "_aagroup", "_side", "_army", "_aaVic", "_truck", "_MarkerColour", "_typeofAAs"];

_markers    = [];
_units      = []; // To clean up units + groups at end
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.

 _army = selectRandom ["AAF", "CSAT", "AAF", "CSAT Pacific"];

_army call {
	if (_this isEqualto "CSAT") exitwith {
		_aaVic = "O_APC_Tracked_02_AA_F";
		_truck = "O_Truck_03_ammo_F";
		_side = east;
		_MarkerColour = "colorOPFOR";
		_typeofAAs = [_aaVic,"O_Radar_System_02_F","O_SAM_System_04_F"];
        [_aaVic, _truck, _side, _MarkerColour, _typeofAAs];
	};


	if (_this isEqualto "AAF") exitwith {
		_aaVic = "I_LT_01_AA_F";
		_truck = "I_Truck_02_ammo_F";
		_side = resistance;
		_MarkerColour = "ColorGUER";
		_typeofAAs = [_aaVic];
        [_aaVic, _truck, _side, _MarkerColour, _typeofAAs];
	};

	if (_this isEqualto "CSAT Pacific") exitwith {
		_aaVic = "O_T_APC_Tracked_02_AA_ghex_F";
		_truck = "O_Truck_03_ammo_F";
		_side = east;
		_MarkerColour = "colorOPFOR";
		_typeofAAs = [_aaVic,"O_Radar_System_02_F","O_SAM_System_04_F"];
        [_aaVic, _truck, _side, _MarkerColour, _typeofAAs];
	};
} params ["_aaVic", "_truck", "_side", "_MarkerColour", "_typeofAAs"];


///////////////////////////////////////////////////////////
// AO Setup
///////////////////////////////////////////////////////////

private _AOSize = 400;
private _ObjectPosition = [0,0];

while { _ObjectPosition isEqualTo [0,0] } do {

    // Blacklist areas, 2km around the areas of operations
    _blacklist = (BASE_PROTECTION_AREAS apply { [getMarkerPos _x] + (getMarkerSize _x apply { _x + 750 }) + [markerDir _x, markerShape _x == "RECTANGLE"] } )
           + (GVAR(missionAreas) apply { [getMarkerPos _x] + (getMarkerSize _x apply { _x + 750 }) + [markerDir _x, markerShape _x == "RECTANGLE"] } );

    // whitelist an area of 3km around said areas
    _whitelist = _blacklist apply { _r = _x + []; _r set [1, (_x select 1) + 1000]; _r set [2, (_x select 2) + 1000]; _r };

    // Now just find a location 2 AOsizes away from players
    _ObjectPosition = [_whitelist, _blacklist + ["water"], {
        { _x distance2D _this < (_AOSize * 2) } count allPlayers isEqualTo 0 && !(_this isFlatEmpty [0,-1,0.4,5,0,false] isEqualTo [])
    }] call BIS_fnc_randomPos;

};

// Now find a location for our AO center position fuzz the HQ...
private _AOPosition = [_ObjectPosition, 0, _AOSize*0.8] call YFNC(getPosAround);

_missionID = call FNC(getMissionID);

// Hide any terrain and slam down the HQ
private _hiddenTerrainKey = format["HT_%1", _missionID];
[clientOwner, _hiddenTerrainKey, _ObjectPosition, 30] remoteExec [QYFNC(hideTerrainObjects), 2];

// Wait for the server to send us back
waitUntil { !isNil {  missionNamespace getVariable _hiddenTerrainKey } };

///////////////////////////////////////////////////////////
// Spawn AA + Crew
///////////////////////////////////////////////////////////

private _dir = random 360;

_AA1 = createVehicle [_aaVic, _ObjectPosition getPos [10,0], [], 0, "NONE"];
_AA2 = createVehicle [selectRandom _typeofAAs, _ObjectPosition getPos [10,120], [], 0, "NONE"];
_AA3 = createVehicle [selectRandom _typeofAAs, _ObjectPosition getPos [10,240], [], 0, "NONE"];

_v   = createVehicle [_truck,     _ObjectPosition getPos [30,random  360], [], 0, "NONE"];
_v setDir _dir;
_v lock 3;

_vehicles pushBack _AA1;
_vehicles pushBack _AA2;
_vehicles pushBack _AA3;
_vehicles pushBack _v;

_aagroup = createGroup _side;
_aagroup setGroupIdGlobal [format ["aa_crew_%1", _missionID]];

// set a bunch of stuff, including unlimited ammo
{
    // Vehicle Settiings
    _x setDir _dir;
    _x addEventHandler ["Fired",{(_this select 0) setVehicleAmmo 1}];
    _x setVehicleRadar 1;
    _x setVehicleReceiveRemoteTargets true;
    _x setVehicleReportRemoteTargets true;
    _x lock 3;
    _x allowCrewInImmobile true;
    _x setFuel 0;

    // Crew
    [_x, _aagroup] call BIS_fnc_spawnCrew;

} forEach [_AA1, _AA2, _AA3];

_aagroup setBehaviour "COMBAT";
_aagroup setCombatMode "RED";
_aagroup allowFleeing 0;

_units append (units _aagroup);

///////////////////////////////////////////////////////////
// H-Barrier
///////////////////////////////////////////////////////////

private _distance = 18;
private _dir = 0;
for "_c" from 1 to 8 do {
    _pos = _ObjectPosition getPos [_distance, _dir];
    _barrier = "Land_HBarrierBig_F" createVehicle _pos;
    _barrier setDir _dir;
    _barrier allowDamage false;
    _barrier setVectorUp surfaceNormal position _barrier;

    _buildings pushBack _barrier;
    _dir = _dir + 45;
};

///////////////////////////////////////////////////////////
// Protection Force - Infantry Only - between 6 and 8
///////////////////////////////////////////////////////////

// Then the rest of the AO
([format["aa_pa_%1", _missionID], _ObjectPosition, _AOSize/2, _army, [0], [3,2], nil, nil, [0], [0], [0], [0], [0], [0]] call SFNC(populateArea)) params ["_spUnits", "_spVehs"];
_units append _spUnits;
_vehicles append _spVehs;

///////////////////////////////////////////////////////////
// Start Mission
///////////////////////////////////////////////////////////

[ _units + _vehicles + _buildings, true] call YFNC(addEditableObjects);

// Bring in the Markers
_markers = [_missionID, _AOPosition, _AOSize, nil, nil, nil, _MarkerColour] call FNC(createMapMarkers);

[
    west,
    _missionID,
    [
        "Forces are setting up an anti-air battery to hit you guys damned hard! We've picked up their positions with thermal imaging scans and have marked it on your map. This is a priority target, boys! They're just setting up now",
        "Priority Target: Anti-air",
        ""
    ],
    _AOPosition,
    false,
    0,
    true,
    "destroy",
    true
] call BIS_fnc_taskCreate;

///////////////////////////////////////////////////////////
// Mission Complete PFH
///////////////////////////////////////////////////////////

_pfh = {
    scopeName "mainPFH";

    params ["_args", "_pfhID"];
    _args params ["_missionID", "_stage", "_hiddenTerrainKey", "_checkPos", "_aagroup", "_aaBattery"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && {_stage < 3}) then { _stage = 2; };

    // Now make sure the prototype tank is dead
    if (_stage isEqualTo 1 && { not _stopRequested }) then {

        // Once they all can't fire, it's game over
        if (({ canFire _x } count _aaBattery) isEqualTo 0) then {
            _stage = 2; _args set [1,_stage];
        } else {
            // Shall we fire ?
            _targets = _checkPos nearEntities [["Air"],5000] select { side _x isEqualTo west && { [objNull, "FIRE"] checkVisibility [_checkPos, getPosASL _x] > 0.5  } };
            if !(_targets isEqualTo []) then {

                // Reveal targets to the AI
                {_aagroup reveal [_x,4];} forEach _targets;

                // Command Fire
                {
                    if (canFire _x) then {
                        _t = selectRandom _targets;
                        _x doWatch _t;
                        _x doTarget _t;
                        _x doFire _t;
                        _x fireAtTarget [_t];
                    };
                } forEach _aaBattery;
            };
        };
    };

    // We have stage 2 just to set the params to avoid executing it each time whilst waiting for cleanup
    if (_stage isEqualTo 2) then {

        // Give them some points
        if !(_stopRequested) then {
            [350, "prio aa"] call YFNC(addRewardPoints);
            parseText format ["<t align='center' size='2.2'>Priority Mission</t><br/><t size='1.5' align='center' color='#34DB16'>Anti-Air</t><br/>____________________<br/>Good work, That should make life better for pilots. You have received %1 credits to compensate your efforts!", 500] call YFNC(globalHint);
        };

        _stage = 3; _args set [1,_stage];

        [_missionID, 'Succeeded', not _stopRequested] call BIS_fnc_taskSetState;
        [_missionID, _stage, "CLEANUP"] call FNC(updateMission);

    };

    if (_stage isEqualTo 3) then {
        // Initiate default cleanup function to clean up officer group + group
        if ([_pfhID, _missionID, _stopRequested] call FNC(missionCleanup)) then {
            [_hiddenTerrainKey] remoteExec [QYFNC(showTerrainObjects), 2];
        };
    };
};

// Enable players to drop onto this mission
[(_markers select 0)] call FNC(setupParadrop);

// For now just start it
[_missionID, "PM", 1, "aa", "", _markers, _units, _vehicles, _buildings, _pfh, 3, [_missionID, 1, _hiddenTerrainKey, getPosASL _AA1, _aagroup, [_AA1, _AA2, _AA3]]] call FNC(startMissionPFH);
