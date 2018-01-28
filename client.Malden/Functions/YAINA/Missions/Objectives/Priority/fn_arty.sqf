/*
   Author:
      Quiksilver
      Rarek [AW]
      MartinCo
	description: none
	returns: nothing
*/

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
        { _x distance2D _this < (_AOSize * 2) } count allPlayers isEqualTo 0 && !(_this isFlatEmpty [5,-1,0.2,5,0,false] isEqualTo [])
    }] call BIS_fnc_randomPos;
};

_missionID = call FNC(getMissionID);

///////////////////////////////////////////////////////////
// Spawn 2 arty + ammo truck
///////////////////////////////////////////////////////////

private ["_g", "_rdir", "_arty1", "_arty2", "_v"];
private _rdir = random 360;

_arty1 = "O_MBT_02_arty_F" createVehicle (_ObjectPosition vectorAdd [-3,-3,0]);
_arty1 setDir _rdir;
_arty1 lock 3;
_arty1 setFuel 0;
_arty1 allowCrewInImmobile true;
_arty1 addEventHandler ["Fired", {(_this select 0) setvehicleammo 1}];
_vehicles pushBack _arty1;

_arty2 = "O_MBT_02_arty_F" createVehicle (_ObjectPosition vectorAdd [3,3,0]);
_arty2 setDir _rdir;
_arty2 lock 3;
_arty2 setFuel 0;
_arty2 allowCrewInImmobile true;
_arty2 addEventHandler ["Fired", {(_this select 0) setvehicleammo 1}];
_vehicles pushBack _arty2;

_v = "O_Truck_03_ammo_F" createVehicle (_ObjectPosition vectorAdd [20,random 20,0]);
_v setDir random 360;
_vehicles pushBack _v;

///////////////////////////////////////////////////////////
// Arty Crew
///////////////////////////////////////////////////////////

_g = createGroup east;
_g setGroupIdGlobal [format ["%1_ArtyCrew", _missionID]];
[_arty1, _g] call BIS_fnc_spawnCrew;
[_arty2, _g] call BIS_fnc_spawnCrew;
[_g, 4] call SFNC(setUnitSkill);
_groups pushBack _g;

{
	_x setBehaviour "COMBAT";
	_x setCombatMode "RED";
	_x allowFleeing 0;
	true;
} count (units _g);


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
([_missionID, _ObjectPosition, _AOSize/2, 0, nil, 6, 0, 1, 0, 2] call SFNC(populateArea)) params ["_spGroups", "_spVehs"];

_groups append _spGroups;
_vehicles append _spVehs;

///////////////////////////////////////////////////////////
// Start Mission
///////////////////////////////////////////////////////////

{ [units _x] call YFNC(addEditableObjects); true; } count _groups;
[ _vehicles + _buildings, true] call YFNC(addEditableObjects);

// Bring in the Markers
_markers = [_missionID, _ObjectPosition, _AOSize] call FNC(createMapMarkers);

[
    west,
    _missionID,
    [
        "OPFOR forces are setting up an artillery battery to hit you guys damned hard! We've picked up their positions with thermal imaging scans and have marked it on your map. This is a priority target, boys! They're just setting up now; they'll be firing in about five minutes!",
        "Priority Target: Artillery",
        ""
    ],
    _ObjectPosition,
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
    _args params ["_missionID", "_stage", "_arty1", "_arty2", "_pfhStart", "_nextStrike"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && {_stage < 3}) then { _stage = 2; };


    // Now make sure the prototype tank is dead
    if (_stage isEqualTo 1 && { not _stopRequested }) then {
        if (!canFire _arty1 && !canFire _arty2) then {
            _stage = 2; _args set [1,_stage];
        } else {
            // We process if we should fire based on _nextStrike, we use
            if (serverTime > _nextStrike) then {
                // We only fire on folks who are within the paradrop markers of an AO
                private _aos = (GVAR(paradropMarkers) apply { [getMarkerPos _x] + (getMarkerSize _x apply { _x * 1.5 }) + [0,false] });
                private _target = selectRandom (allPlayers select { _p = _x; side _x isEqualTo west && { !(({ _p inArea _x } count _aos) isEqualTo 0) } && { (getPos _p) inRangeOfArtillery [[_arty1, _arty2], "32Rnd_155mm_Mo_shells"] } } );

                if !(isNil "_target") then {
                    // We have a target, FIRE
                    private _targetPos = getPosATL player;
                    private _targetDir = [_arty1, _targetPos] call BIS_fnc_dirTo;

                    if (canFire _arty1) then {
                        _arty1 commandArtilleryFire [ [_targetPos, 30] call BIS_fnc_randomPosTrigger, "32Rnd_155mm_Mo_shells", floor(random 5) + 2];
                    };

                    // Trigger _arty2 in 5 seconds so the target area is bathed in arty
                    [{
                        params ["_arty2", "_dir", "_target"];
                        if (canFire _arty2) then {
                            _arty2 commandArtilleryFire [ [_target, 30] call BIS_fnc_randomPosTrigger, "32Rnd_155mm_Mo_shells", floor(random 5) + 2];
                        };
                    }, [_arty2, _targetDir, _targetPos], 5] call CBAP_fnc_waitAndExecute;

                    // Players get between 30 and 40 seconds to move
                    _warningTime = (random 10) + 30;
                    _shellETA    = (_arty1 getArtilleryETA [ _targetPos, "32Rnd_155mm_Mo_shells" ]) max (_arty2 getArtilleryETA [ _targetPos, "32Rnd_155mm_Mo_shells" ]);
                    _sleepTime   = floor(_shellETA - _warningTime) max 1;

                    // Give a little warning
                    [{ "SmokeShellRed" createVehicle (_this select 0) }, [_targetPos], _sleepTime] call CBAP_fnc_waitAndExecute;

                    // If it's night, we fire a flare above them and hope they see it...
                    if (daytime > 20 || { daytime < 4}) then {
                        [{ _v = "F_20mm_Red" createVehicle (_this select 0); _v setVelocity [0,0,-0.5] }, [_target modelToWorld [random[-30,0,30],10 + random 30,160]], _sleepTime] call CBAP_fnc_waitAndExecute;
                    };

                    // Then we sleep for a long time between fires, between 10 and 20 minutes
                    // If however, an HC failover occurs, then it'll be back to the initial
                    // wait period, which is ok
                    _args set [5, serverTime + 600 + random 600];
                } else {
                    // No targets found, don't bother checking for another 2 or 3 minutes
                    _args set [5, serverTime + 120 + random 60];
                };
            };
        };
    };

    // We have stage 2 just to set the params to avoid executing it each time whilst waiting for cleanup
    if (_stage isEqualTo 2) then {

        // Give them some points
        if !(_stopRequested) then {
            [350, "prio arty"] call YFNC(addRewardPoints);
            parseText format ["<t align='center' size='2.2'>Priority Mission</t><br/><t size='1.5' align='center' color='#34DB16'>Artillery</t><br/>____________________<br/>Good work, That should make life better for those on the ground. You have received %1 credits to compensate your efforts!", 500] call YFNC(globalHint);
        };

        _stage = 3; _args set [1,_stage];

        [_missionID, 'Succeeded', not _stopRequested] call BIS_fnc_taskSetState;
        [_missionID, _stage, "CLEANUP"] call FNC(updateMission);

    };

    if (_stage isEqualTo 3) then {
        // Initiate default cleanup function to clean up officer group + group
        [_pfhID, _missionID, _stopRequested] call FNC(missionCleanup);
    };
};

// Enable players to drop onto this mission
[(_markers select 0)] call FNC(setupParadrop);

// For now just start it
[_missionID, "PM", 1, "artillery", "", _markers, _groups, _vehicles, _buildings, _pfh, 5, [_missionID, 1, _arty1, _arty2, serverTime, serverTime + 120 + random 60]] call FNC(startMissionPFH);
