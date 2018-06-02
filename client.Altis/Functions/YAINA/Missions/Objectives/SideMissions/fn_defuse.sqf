/*
Function: YAINA_MM_OBJ_fnc_defuse

Description:
	Defuse a bomb in a limited amount of time, or a bunch of civilians will blown up.
    Randomly selects one of the following armies for populating the mission:

    AAF, CSAT, CSAT Pacific, Syndikat

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Matth
*/

#include "..\..\defines.h"

// We always start with these 6, as they're in every mission
private ["_missionID", "_pfh", "_markers", "_units", "_vehicles", "_buildings", "_side", "_MarkerColour"];

_markers    = [];
_units      = []; // To clean up units at end
_vehicles   = []; // To delete at end
_buildings  = []; // To restore at end, NB: if you're spawning buildings, add them to this
                  // So that they get restored, before your clean up deletes them, as arma
                  // replaces objects, if you don't restore them, then the destroyed version
                  // will persist.
				  
				  
_army = selectRandom ["CSAT","AAF","CSAT Pacific","Syndikat"];

switch (_army) do {
    case "CSAT": {
		_side = east;
		_MarkerColour = "colorOPFOR";
		};
    case "AAF": {
		_side = resistance;
		_MarkerColour = "ColorGUER";
		};
    case "CSAT Pacific": {
		_side = east;
		_MarkerColour = "colorOPFOR";
		};
    case "Syndikat": {
		_side = resistance;
		_MarkerColour = "ColorGUER";
		};
    default {
		_side = east;
		_MarkerColour = "colorOPFOR";
		};
};

///////////////////////////////////////////////////////////
// Location Scout
///////////////////////////////////////////////////////////

private ["_AOPosition", "_HQPos", "_nearestTown"];
private _AOSize = 400;

_HQPos = [0,0];
while { _HQPos isEqualTo [0,0] } do {
    _HQPos = [nil, ([_AOSize] call FNC(getAOExclusions)) + ["water"], {
        { _x distance2D _this < (_AOSize * 2) } count allPlayers isEqualTo 0 && !(_this isFlatEmpty [-1,-1,0.25,25,0,false] isEqualTo [])
    }] call BIS_fnc_randomPos;
};

// Now find a location for our AO center position fuzz the HQ...
_AOPosition = [_HQPos, 20, _AOSize*0.9] call YFNC(getPosAround);

// Find our nearest town + direction for mission description
_nearestTown = [_AOPosition] call YFNC(dirFromNearestName);

// Mission Description
private _missionDescription = format["Conquest: %1 of %2", _nearestTown select 2, text (_nearestTown select 0)];

///////////////////////////////////////////////////////////
// Spawn Conquest HQ, Crate and Civs
///////////////////////////////////////////////////////////

private ["_cqFunc"];

// Now we have our HQ + Location, bring in the HQ
_missionID = call FNC(getMissionID);


// Hide any terrain and slam down the HQ
private _hiddenTerrainKey = format["HT_%1", _missionID];
[clientOwner, _hiddenTerrainKey, _HQPos, 30] remoteExec [QYFNC(hideTerrainObjects), 2];

// Wait for the server to send us back
waitUntil { !isNil {  missionNamespace getVariable _hiddenTerrainKey } };

//Spawn HQ
private _hq = "Land_Cargo_HQ_V1_F" createVehicle _HQPos;
private _bomb = "cargonet_01_barrels_f" createVehicle [0,0,0];
_bomb setPos (getPos _hq vectorAdd [0,0,2]);
_buildings   = [_hq, _bomb];

private _civTypes = ["C_man_polo_1_F", "C_man_1", "C_man_polo_2_F", "C_man_polo_3_F", "C_man_polo_4_F", "C_man_polo_5_F", "C_man_polo_6_F", "C_man_p_fugitive_F"];
private _civGroup = createGroup civilian;
_civGroup setGroupIdGlobal [format["SMDefuse_civs_%1", _missionID]];
private _civ1 = _civGroup createUnit [(selectRandom _civTypes), (getPos _hq vectorAdd [2,0,1]), [], 0, "NONE"];
private _civ2 = _civGroup createUnit [(selectRandom _civTypes), (getPos _hq vectorAdd [2,2,1]), [], 0, "NONE"];
private _civ3 = _civGroup createUnit [(selectRandom _civTypes), (getPos _hq vectorAdd [2,-2,1]), [], 0, "NONE"];
private _civ4 = _civGroup createUnit [(selectRandom _civTypes), (getPos _hq vectorAdd [-2,2,1]), [], 0, "NONE"];
private _civ5 = _civGroup createUnit [(selectRandom _civTypes), (getPos _hq vectorAdd [-2,-2,1]), [], 0, "NONE"];

{
_x action ["Surrender", _x];
_x setDamage 0.8;
_x setdir random 360;
_units append [_x];
} foreach [_civ1, _civ2, _civ3, _civ4, _civ5];

///////////////////////////////////////////////////////////
// Spawn Enemies
///////////////////////////////////////////////////////////

// Then the rest of the AO
([format["defuse_pa_%1", _missionID], _HQPos, _AOSize/2, _side, _army, [2, 30, 75]] call SFNC(populateArea)) params ["_spUnits", "_spVehs"];

_units append _spUnits;
_vehicles append _spVehs;

///////////////////////////////////////////////////////////
// Defuse Function
///////////////////////////////////////////////////////////
// Syntax of AIS_Core_fnc_Progress_ShowBar is Text, Time, Code block (what to do), target thing, fail code


private _bombObj = _bomb;
_bombObj setVariable [QVAR(missionID), _missionID, true];

[_bombObj, {}, "<t color='#ff1111'>Defuse Bomb</t>", {
    params ["_target", "_caller", "_id", "_arguments"];
    // We set serverTime to now, in case of a DC whilst downloading, we
    // dont want the mission to bug out
    _target setVariable[QVAR(defusing), serverTime, true];

    // Side message telling folks who's doing it
    [[west, "HQ"], format ["%1 is defusing the bomb!",name player]] remoteExec ["sideChat"];

    ["Defusing the Bomb...", 10, {
        // Success, move onto verify
        params ["_target"];

        // Refresh our download time
        _target setVariable [QVAR(defusing), serverTime, true];
		
		[[west, "HQ"], format ["%1 has successfully defused the bomb.", name player]] remoteExec ["sideChat"];
        _target setVariable[QVAR(defused), true, true];
    }, [_target], {
        // on Abort;
        params ["_target"];
        _target setVariable[QVAR(defusing), 0, true];
        [[west, "HQ"], "Bomb was not defusing, we need to try again!"] remoteExec ["sideChat"];
    }] call AIS_Core_fnc_Progress_ShowBar;

}, [], 6, false, true, "", format["alive _target && { serverTime - (_target getVariable['%1', 0]) > 12 } && { not (_target getVariable['%2', false]) }", QVAR(defusing), QVAR(defused)], 5, false] call YFNC(addActionMP);

///////////////////////////////////////////////////////////
// Start Mission
///////////////////////////////////////////////////////////

// Bring in the Markers
_markers = [_missionID, _AOPosition, _AOSize, nil, nil, nil, _MarkerColour] call FNC(createMapMarkers);

// Add everything to zeus
[_units + _buildings + _vehicles, true] call YFNC(addEditableObjects);

// Set the mission in progress
[
    west,
    _missionID,
    [
        format ["%1 are preparing to blow up civilians who they believe leaked weapons plans to NATO. Save those Civilians!", _army],
        format ["Defuse the Bomb %1 of %2", _nearestTown select 2, text (_nearestTown select 0)],
        ""
    ],
    _AOPosition,
    false,
    10,
    true,
    "Attack",
    true
] call BIS_fnc_taskCreate;


// Build the progression PFH
_pfh = {
    scopeName "mainPFH";

    params ["_args", "_pfhID"];
    _args params ["_missionID", "_stage", "_AOPosition", "_bombObj", "_active", "_startTime", "_units", "_HQPos", "_bomb"];

    // Stop requested ?
    _stopRequested = _missionID in GVAR(stopRequests);
    if (_stopRequested && {_stage < 3}) then { _stage = 3; };

    if (_stage isEqualTo 1) then {
        if (_bombObj getVariable [QVAR(defused), false]) then {
            _stage = 3; _args set [1, _stage];
        } else {
			
			if (_active isEqualTo TRUE) then {
					if (_startTime + 900 < LTIME) then {
					private _explosive = "ModuleExplosive_SatchelCharge_F" createVehicle _HQPos;
					_explosive setDamage 1;
					deleteVehicle _bomb;
					_stage = 2; _args set [1,_stage];
					};				
				} else {
				if (!( ({ _x isEqualTo true } count (_units apply { _x call BIS_fnc_enemyDetected; })) isEqualTo 0)) then {
					// Time to move, we can move, not moving currently (wp in progress) and spotted the players
						parseText format ["<t align='center'><t size='2'>Side Mission</t><br/><t size='1.5' color='#08b000'>PROGRESS</t><br/>____________________<br/><br/>The Enemy have detected you and began a 15 minute timer on the bomb. Save those Civilians before its too late!"] call YFNC(globalHint);
					_startTime = LTIME;
					_args set [5,_startTime];
					_active = TRUE;
					_args set [4,_active];
				};
			};
        };
    };

    if (_stage isEqualTo 2) then {
        if (_bombObj getVariable [QVAR(defused), false]) then {
            _stage = 3; _args set [1, _stage];
        } else {

            // If once moved, players are > 500m away, then it's failed
            private _c =  { _x distance2D _bombObj < 500 } count allPlayers;
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

                if (_bombObj getVariable [QVAR(defused), false]) then {
                    [500, "Defuse"] call YFNC(addRewardPoints);
					parseText format ["<t align='center' size='2.2'>Side Mission</t><br/><t size='1.5' align='center' color='#34DB16'>Bomb Defused</t><br/>____________________<br/>You have saved the Civilians. You have received %1 credits to compensate your efforts!", 500] call YFNC(globalHint);
                    _mNotify = true;
					
                } else {
                    // failure
                    [-500, "Bomb Exploded"] call YFNC(addRewardPoints);
                    parseText format ["<t align='center'><t size='2.2'>Side Mission</t><br/><t size='1.5' color='#FF0808'>FAILED</t><br/>____________________<br/> Mission Failed! The Civilians were killed! We've just lost %1 credits to compensate the familys. Move in faster next time.</t>",500] call YFNC(globalHint);
                    _mState = "Failed";
                };
            };
			
        // Set the defused to true, so the action isn't available any longer (
        // in case of escape where the vehicle is still alive
        if !(isNull _bombObj) then {
            _bombObj setVariable[QVAR(defused), true, true];
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
[_missionID, "SM", 1, "defuse", "", _markers, _units, _vehicles, _buildings, _pfh, 3, [_missionID, 1, _AOPosition, _bombObj, FALSE, 0, _units, _HQPos, _bomb]] call FNC(startMissionPFH);
