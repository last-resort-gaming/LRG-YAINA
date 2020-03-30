/*
Function: YAINA_MM_OBJ_fnc_arty

Description:
	Priority Target: Artillery. The artillery installation engages BLUFOR targets
    once they have been discovered, deploying red smoke on target for range indication and
    tuning.
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
	Matt - location function
*/

#include "..\..\defines.h"

// We always start with these 6, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings", "_g", "_rdir", "_arty1", "_arty2", "_v", "_side", "_artVic", "_truck", "_MarkerColour"];

_markers    = [];
_units      = []; // To clean up units
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.

 _army = selectRandom ["AAF", "CSAT", "AAF", "CSAT Pacific"];

_army call {
	if (_this isEqualto "CSAT") exitwith {
		_artVic = "O_MBT_02_arty_F";
		_truck = "O_Truck_03_ammo_F";
		_side = east;
		_MarkerColour = "colorOPFOR";
        [_artVic, _truck, _side, _MarkerColour];
	};

	if (_this isEqualto "AAF") exitwith {
		_artVic = "I_Truck_02_MRL_F";
		_truck = "I_Truck_02_ammo_F";
		_side = resistance;
		_MarkerColour = "ColorGUER";
        [_artVic, _truck, _side, _MarkerColour];
	};

	if (_this isEqualto "CSAT Pacific") exitwith {
		_artVic = "O_T_MBT_02_arty_ghex_F";
		_truck = "O_T_Truck_03_ammo_ghex_F";
		_side = east;
		_MarkerColour = "colorOPFOR";
        [_artVic, _truck, _side, _MarkerColour];
	};
} params ["_artVic", "_truck", "_side", "_MarkerColour"];
///////////////////////////////////////////////////////////
// AO Setup
///////////////////////////////////////////////////////////

private _AOSize = 400;
private _ObjectPosition = [0,0];

private _pos = [_AOSize, "LAND", "FLAT"] call YFNC(AOPos);

_ObjectPosition = _pos select 0;

// Now find a location for our AO center position fuzz the HQ...
private _AOPosition = _pos select 1;

_missionID = call FNC(getMissionID);

///////////////////////////////////////////////////////////
// Spawn 2 arty + ammo truck
///////////////////////////////////////////////////////////


private _rdir = random 360;

_arty1 = _artVic createVehicle (_ObjectPosition vectorAdd [-3,-3,0]);
_arty1 setDir _rdir;
_arty1 lock 3;
_arty1 setFuel 0;
_arty1 allowCrewInImmobile true;
_arty1 addEventHandler ["Fired", {(_this select 0) setvehicleammo 1}];
_vehicles pushBack _arty1;

_arty2 = _artVic createVehicle (_ObjectPosition vectorAdd [3,3,0]);
_arty2 setDir _rdir;
_arty2 lock 3;
_arty2 setFuel 0;
_arty2 allowCrewInImmobile true;
_arty2 addEventHandler ["Fired", {(_this select 0) setvehicleammo 1}];
_vehicles pushBack _arty2;

_v = _truck createVehicle (_ObjectPosition vectorAdd [20,random 20,0]);
_v setDir random 360;
_vehicles pushBack _v;

///////////////////////////////////////////////////////////
// Arty Crew
///////////////////////////////////////////////////////////

_g = createGroup _side;
_g setGroupIdGlobal [format ["arty_crew_%1", _missionID]];
[_arty1, _g] call BIS_fnc_spawnCrew;
[_arty2, _g] call BIS_fnc_spawnCrew;
[_g, "LRG Default"] call SFNC(setUnitSkill);
_units append (units _g);

{
	_x setBehaviour "COMBAT";
	_x setCombatMode "RED";
	_x allowFleeing 0;
	true;
} count _units;


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
        "Forces are setting up an artillery battery to hit you guys damned hard! We've picked up their positions with thermal imaging scans and have marked it on your map. This is a priority target, boys! They're just setting up now; they'll be firing in about five minutes!",
        "Priority Target: Artillery",
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
    _args params ["_missionID", "_stage", "_arty1", "_arty2", "_nextStrike", "_side"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && {_stage < 3}) then { _stage = 2; };


    // Now make sure the prototype tank is dead
    if (_stage isEqualTo 1 && { not _stopRequested }) then {
        if ((!canFire _arty1) && (!canFire _arty2)) then {
            _stage = 2; _args set [1,_stage];
        } else {
            // We process if we should fire based on _nextStrike, we use
            _currTime = LTIME;
            if (_currTime > _nextStrike) then {
                // We only fire on folks who are within the paradrop markers of an AO
                private _aos = (GVAR(missionAreas) apply { [getMarkerPos _x] + (getMarkerSize _x apply { _x * 1.5 }) + [0,false] });
				if (_side isEqualTo east) then {
                    _target = selectRandom (allPlayers select { _p = _x; side _x isEqualTo west && { !(({ _p inArea _x } count _aos) isEqualTo 0) } && { (getPos _p) inRangeOfArtillery [[_arty1, _arty2], "32Rnd_155mm_Mo_shells"] } && { east knowsAbout _p >= 1.5 }  } );
				};
				if (_side isEqualTo resistance) then {
                    _target = selectRandom (allPlayers select { _p = _x; side _x isEqualTo west && { !(({ _p inArea _x } count _aos) isEqualTo 0) } && { (getPos _p) inRangeOfArtillery [[_arty1, _arty2], "12Rnd_230mm_rockets"] } && { resistance knowsAbout _p >= 1.5 }  } );
				};
                if !(isNil "_target") then {
                    // We have a target, FIRE

                    private _mainArty  = ([_arty1, _arty2] select { canFire _x }) select 0;

                    private _targetPos = getPos _target;
                    private _targetDir = [_mainArty, _targetPos] call BIS_fnc_dirTo;

                    if (canFire _arty1) then {
						if (_side isEqualTo east) then {
                            _arty1 commandArtilleryFire [ [_targetPos, 30] call BIS_fnc_randomPosTrigger, "32Rnd_155mm_Mo_shells", floor(random 5) + 2];
						};
						if (_side isEqualTo resistance) then {
                            _arty1 commandArtilleryFire [ [_targetPos, 30] call BIS_fnc_randomPosTrigger, "12Rnd_230mm_rockets", 1];
						};
                    };

                    // Trigger _arty2 in 5 seconds so the target area is bathed in arty
                    [{
                        params ["_arty2", "_dir", "_target", "_side", "_targetPos"];
                        if (canFire _arty2) then {
							if (_side isEqualTo east) then {
							    _arty2 commandArtilleryFire [ [_targetPos, 30] call BIS_fnc_randomPosTrigger, "32Rnd_155mm_Mo_shells", floor(random 5) + 2];
							};
							if (_side isEqualTo resistance) then {
							    _arty2 commandArtilleryFire [ [_targetPos, 30] call BIS_fnc_randomPosTrigger, "12Rnd_230mm_rockets", 1];
							};
                        };
                    }, [_arty2, _targetDir, _targetPos, _side, _targetPos], 5] call CBA_fnc_waitAndExecute;

                    // Players get between 30 and 40 seconds to move
                    _warningTime = (random 10) + 30;
                    _shellETA    = _mainArty getArtilleryETA [ _targetPos, "32Rnd_155mm_Mo_shells" ];
                    _sleepTime   = floor(_shellETA - _warningTime) max 1;

                    // Give a little warning
                    [{ "SmokeShellRed" createVehicle (_this select 0) }, [_targetPos], _sleepTime] call CBA_fnc_waitAndExecute;

                    // If it's night, we throw some chemlights down too
                    if (daytime > 20 || { daytime < 4}) then {
                        [{ params ["_tp"]; "Chemlight_red" createVehicle (_tp vectorAdd [1,1,0]); "Chemlight_red" createVehicle (_tp vectorAdd [-1,-1,0]); }, [_targetPos], _sleepTime] call CBA_fnc_waitAndExecute;
                    };

                    // Then we sleep for a long time between fires, between 10 and 20 minutes
                    // If however, an HC failover occurs, then it'll be back to the initial
                    // wait period, which is ok
                    _args set [4, _currTime + 600 + random 600];
                } else {
                    // No targets found, don't bother checking for another 2 or 3 minutes
                    _args set [4, _currTime + 120 + random 60];
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
        [_pfhID, _missionID, _stopRequested] call FNC(missionCleanup);
    };
};

// Enable players to drop onto this mission
[(_markers select 0)] call FNC(setupParadrop);

// For now just start it
[_missionID, "PM", 1, "arty", "", _markers, _units, _vehicles, _buildings, _pfh, 5, [_missionID, 1, _arty1, _arty2, LTIME + 120 + random 60, _side]] call FNC(startMissionPFH);
