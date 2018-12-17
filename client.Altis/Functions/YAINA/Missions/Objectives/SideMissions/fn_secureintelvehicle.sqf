/*
Function: YAINA_MM_OBJ_fnc_secureintelvehicle

Description:
	Recover intel from a HVT transported in a vehicle. If the driver sees, they will try
    to get away. If escape is successful, the mission fails. Likewise, if the vehicle and
    the intel inside is detroyed, the mission also fails.

    If the vehicle is secured and the intel found, mission success.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Quiksilver - Original Mission Idea
    Stanhope - Mission Updated and Fixed
    Martin - Ported to YAINA
*/

#define OBJVEH_TYPES "O_MRAP_02_F","I_MRAP_03_F"
#define OBJUNIT_TYPES "O_officer_F","O_Soldier_SL_F","O_recon_TL_F","O_diver_TL_F"
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

_army = "CSAT";
_side = east;
///////////////////////////////////////////////////////////
// AO Setup
///////////////////////////////////////////////////////////

private _AOSize = 400;
private _ObjectPosition = [0,0];

private _pos = [_AOSize, "LAND", "FLAT"] call YFNC(AOPos);

_ObjectPosition = _pos select 0;

// Suitable location for marker
private _AOPosition = _pos select 1;

private ["_x","_targetTrigger","_aGroup","_bGroup","_cGroup","_objUnit1","_objUnit2","_objUnit3","_obj1","_obj2","_obj3","_off", "_intelObj","_enemiesArray","_randomDir","_poi","_vtype", "_vpos","_position","_accepted","_fuzzyPos","_briefing","_escapeWP"];


// Mission ID Gen
_missionID = call FNC(getMissionID);

///////////////////////////////////////////////////////////
// MISSION OBJECTIVE SPAWNS
///////////////////////////////////////////////////////////

//--------- CREATE GROUP, VEHICLE AND UNIT

_aGroup = createGroup east;
_aGroup setGroupIdGlobal [format["secureintelvehicle_tgta_%1", _missionID]];
_bGroup = createGroup east;
_bGroup setGroupIdGlobal [format["secureintelvehicle_tgtb_%1", _missionID]];
_cGroup = createGroup east;
_cGroup setGroupIdGlobal [format["secureintelvehicle_tgtc_%1", _missionID]];

//--------- OBJ 1

_vtype = selectRandom [OBJVEH_TYPES];
_vpos  = _ObjectPosition findEmptyPosition [5, 30, _vtype];
_obj1 = _vtype createVehicle _vpos;
_obj1 setDir (random 360);

_off = _aGroup createUnit ["O_officer_F", _vpos, [], 5, "NONE"];
_off assignAsDriver _obj1;
_off moveInDriver _obj1;

_units pushBack _off;
_vehicles pushBack _obj1;

//--------- OBJ 2

_vtype = selectRandom [OBJVEH_TYPES];
_vpos  = _ObjectPosition findEmptyPosition [7, 30, _vtype];
_obj2 = _vtype createVehicle _vpos;
_obj2 setDir (random 360);

_off = _bGroup createUnit ["O_officer_F", _vpos, [], 5, "NONE"];
_off assignAsDriver _obj2;
_off moveInDriver _obj2;

_units pushBack _off;
_vehicles pushBack _obj2;
//-------- OBJ 3

_vtype = selectRandom [OBJVEH_TYPES];
_vpos  = _ObjectPosition findEmptyPosition [10, 35, _vtype];
_obj3 = _vtype createVehicle _vpos;
_obj3 setDir (random 360);

_off = _cGroup createUnit ["O_Officer_F", _vpos, [], 5, "NONE"];
_off assignAsDriver _obj3;
_off moveInDriver _obj3;

_units pushBack _off;
_vehicles pushBack _obj3;
///////////////////////////////////////////////////////////
// ASSOCIATE INTEL WITH VEH
///////////////////////////////////////////////////////////

_intelObj = selectRandom [_obj1,_obj2,_obj3];
_intelObj setVariable [QVAR(missionID), _missionID, true];

[_intelObj, {}, "<t color='#ff1111'>Get Intel</t>", {
    params ["_target", "_caller", "_id", "_arguments"];

    // We set serverTime to now, in case of a DC whilst downloading, we
    // dont want the mission to bug out
    _target setVariable[QVAR(intelDownloading), serverTime, true];

    // Side message telling folks who's doing it
    [[west, "HQ"], format ["%1 is securing the intel!",name player]] remoteExec ["sideChat"];

    ["Downloading Intel...", 10, {
        // Success, move onto verify
        params ["_target"];

        // Refresh our download time
        _target setVariable [QVAR(intelDownloading), serverTime, true];

        ["Verifying Intel...", 10, {
            params ["_target"];

            // If the vehicle has moved cos the driver was still in it, lets just make sure were < 6 metersr from it again
            if (player distance2D _target > 6) then {
                // failed
                _target setVariable[QVAR(intelDownloading), 0, true];
                [[west, "HQ"], "Intel failed to verify, we need to try again!"] remoteExec ["sideChat"];
            } else {
                [[west, "HQ"], format ["%1 has successfully secured the intel.", name player]] remoteExec ["sideChat"];
                _target setVariable[QVAR(intelComplete), true, true];
            };

        }, [_target], {
            params ["_target"];
            _target setVariable[QVAR(intelDownloading), 0, true];
            [[west, "HQ"], "Intel failed to verify, we need to try again!"] remoteExec ["sideChat"];
        }] call AIS_Core_fnc_Progress_ShowBar;
    }, [_target], {
        // on Abort;
        params ["_target"];
        _target setVariable[QVAR(intelDownloading), 0, true];
        [[west, "HQ"], "Intel was not secured, we need to try again!"] remoteExec ["sideChat"];
    }] call AIS_Core_fnc_Progress_ShowBar;

}, [], 6, false, true, "", format["alive _target && { serverTime - (_target getVariable['%1', 0]) > 12 } && { not (_target getVariable['%2', false]) }", QVAR(intelDownloading), QVAR(intelComplete)], 5, false] call YFNC(addActionMP);

// KILLED HANDLER
_intelObj addEventHandler ["Killed", {
    params ["_unit", "_killer", "_instigator"];

    if !(_unit getVariable [QVAR(intelComplete), false]) then {
        _instigatorReal = name _instigator;
        if (_instigator isEqualTo objNull) then {
            if (_killer isKindOf "UAV") then {
                _instigatorReal = name ((UAVControl _killer) select 0);
            } else {
                _instigatorReal = name _killer;
            };
        };
        if (isNull _instigatorReal) then { _instigatorReal = "someone"; };

        _vname = format["%1_killed", _unit getVariable QVAR(missionID)];
        missionNamespace setVariable [_vname, true];
        publicVariableServer _vname;

        parseText format ["<t align='center'><t size='2.2'>Side Mission</t><br/><t size='1.5' color='#FF0808'>FAILED</t><br/>____________________<br/> Mission Failed! The Vehicle was destroyed by %2! We've just lost %1 credits as a result. Watch your fire next time.</t>",500,_instigatorReal] call YFNC(globalHint);
    };
}];

///////////////////////////////////////////////////////////
// SPAWN DEFENSES
///////////////////////////////////////////////////////////


for "_x" from 0 to (2 + (random 3)) do {
	_randomPos = [[[_ObjectPosition, 300],[]],["water"]] call BIS_fnc_randomPos;

	_infteamPatrol = [_randomPos, EAST, (configfile >> "CfgGroups" >> "East" >> "OPF_F" >> "Infantry" >> ["OIA_InfTeam","OIA_InfTeam_AT","OIA_InfTeam_AA","OI_reconPatrol","OIA_GuardTeam"] call BIS_fnc_selectRandom)] call BIS_fnc_spawnGroup;
	_infteamPatrol setGroupIdGlobal [format["secureintelvehicle_inf_%1_%2", _x, _missionID]];
	_units append (units _infteamPatrol);

	[_infteamPatrol, _ObjectPosition, 100] call BIS_fnc_taskPatrol;
	[_infteamPatrol, "LRG Default"] call SFNC(setUnitSkill);
};

//---------- RANDOM VEHICLE

private _SMvehPatrol = createGroup east;
_SMvehPatrol setGroupIdGlobal [format["secureintelvehicle_mrap_%1", _missionID]];

_randomPos = [[[_ObjectPosition, 300],[]],["water"]] call BIS_fnc_randomPos;

private _SMveh = ["O_MRAP_02_gmg_F","O_MRAP_02_hmg_F","O_APC_Tracked_02_cannon_F"] call BIS_fnc_selectRandom createVehicle _randomPos;
_vehicles pushBack _SMveh;
_SMveh lock 3;

[_SMveh, _SMvehPatrol] call BIS_fnc_spawnCrew;
[_SMvehPatrol, _ObjectPosition, 150] call BIS_fnc_taskPatrol;
[_SMvehPatrol, "LRG Default"] call SFNC(setUnitSkill);

_units append (units _SMvehPatrol);

if (random 1 >= 0.5) then {
	_SMveh allowCrewInImmobile true;
};

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
        "We have reports from locals that sensitive, strategic information is changing hands. This is a target of opportunity! We've marked the position on your map; head over there and secure the intel. It should be stored on one of the vehicles or on their persons","Side Mission: Secure Intel",
        "Secure Intel Area",
        ""
    ],
    _AOPosition,
    false,
    0,
    true,
    "intel",
    true
] call BIS_fnc_taskCreate;


// Build the progression PFH
_pfh = {
    scopeName "mainPFH";

    params ["_args", "_pfhID"];
    _args params ["_missionID", "_stage", "_AOPosition", "_vehGroups", "_intelObj"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && {_stage < 3}) then { _stage = 3; };

    // kvar: used to store if the vehicle was killed prior to intel
    _kvar = format["%1_killed", _missionID];

    if (_stage isEqualTo 1) then {
        if (!alive _intelObj || { _intelObj getVariable [QVAR(intelComplete), false] }  ) then {
            _stage = 3; _args set [1, _stage];
        } else {
            // The vehicles are still alive, and the intel still attainable, so we just see if any players
            // are near, and if the AI groups know about them, drive teh vehicles off

            if (canMove _intelObj && { !( ({ _x isEqualTo true } count (crew _intelObj apply { _x call BIS_fnc_enemyDetected; })) isEqualTo 0) } ) then {

                // Time to move, we can move, not moving currently (wp in progress) and spotted the players
                [[west, "HQ"], "Target has spotted you and is trying to escape with the intel!"] remoteExec ["sideChat"];

                // Set Moving, if the vehicle never makes it to WP and becomes disabled
                // this doesn't refire, which is what we want

                {
                    _escape1WP = _x addWaypoint [_AOPosition, 300];
                    _escape1WP setWaypointType "MOVE";
                    _escape1WP setWaypointBehaviour "CARELESS";
                    _escape1WP setWaypointSpeed "FULL";
                    _escape1WP setWaypointCompletionRadius 20;
                } forEach _vehGroups;

                // Then we move to just letting the AI do their thing and move when they want
                _stage = 2; _args set [1, _stage];
            };
        };
    };

    if (_stage isEqualTo 2) then {
        if (!alive _intelObj || { _intelObj getVariable [QVAR(intelComplete), false] }  ) then {
            _stage = 3; _args set [1, _stage];
        } else {

            // If once moved, players are > 500m away, then it's failed
            private _c =  { _x distance2D _intelObj < 500 } count allPlayers;
            if (_c isEqualTo 0) then {
                // Failed
                _stage = 3; _args set [1,_stage];
            };
        };
    };

    if (_stage isEqualTo 3) then {
        // Messages and Cleanup

        private _mState = "Succeeded";
        private _mNotify = false;

        if !(_stopRequested) then {

            if (missionNamespace getVariable [_kvar, false]) then {
                [-500, "secure intel"] call YFNC(addRewardPoints);
                _mState = "Failed";
            } else {

                if (_intelObj getVariable [QVAR(intelComplete), false]) then {
                    [500, "secure intel"] call YFNC(addRewardPoints);
                    _mNotify = true;
                } else {
                    // failure
                    [-500, "secure intel escaped"] call YFNC(addRewardPoints);
                    parseText format ["<t align='center'><t size='2.2'>Side Mission</t><br/><t size='1.5' color='#FF0808'>FAILED</t><br/>____________________<br/> Mission Failed! The Officer managed to escape! We've just lost %1 credits as a result. Move in faster next time.</t>",500] call YFNC(globalHint);
                    _mState = "Failed";
                };
            };
        };

        // Clean up Vars
        missionNamespace setVariable [_kvar, nil];
        publicVariableServer _kvar;

        // Set the intelComplete to true, so the action isn't available any longer (
        // in case of escape where the vehicle is still alive
        if !(isNull _intelObj) then {
            _intelObj setVariable[QVAR(intelComplete), true, true];
        };

        // Move onto stage 3 + CLEANUP
        _stage = 4; _args set [1,_stage];
        [_missionID, _mState, _mNotify] call BIS_fnc_taskSetState;
        [_missionID, _stage, "CLEANUP"] call FNC(updateMission);

    };

    if (_stage isEqualTo 4) then {
        [_pfhID, _missionID, _stopRequested] call FNC(missionCleanup);
    };
};


// Enable players to drop onto this mission
[(_markers select 0)] call FNC(setupParadrop);

// For now just start it
[_missionID, "SM", 1, "secure intel (vehicle)", "", _markers, _units, _vehicles, _buildings, _pfh, 3, [_missionID, 1, _AOPosition, [_aGroup, _bGroup, _cGroup], _intelObj]] call FNC(startMissionPFH);
