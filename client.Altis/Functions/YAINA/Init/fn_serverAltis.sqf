/*
Function: YAINA_INIT_fnc_serverAltis

Description:
	Sets up all the modules and objects relevant to the Altis 
    mission file. These are base lighting, the UAVs, the Repair and
    Service installations, the helicopters and other aircrafts,
    the medivac, static medical structures and AA.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

if !(isServer) exitWith {};

///////////////////////////////////////////////////////////
// LIGHTING
///////////////////////////////////////////////////////////

private _baseSize = getMarkerSize "BASE";
_baseSize = (_baseSize select 0) max (_baseSize select 1);

// Normal Lamps around base get the distance set to the base size
private _baseLights =  getMarkerPos "BASE" nearObjects ["Lamps_base_F", _baseSize];
{ _x setLightFlareMaxDistance _baseSize; _x allowDamage false; } forEach _baseLights;

// Ensure the airstrip lights are visible from afar (whole world)
// Then NavLights get infi-distance
private _lightViewDistance = 2 * worldSize * sqrt 2;
private _navLights  = getMarkerPos "BASE" nearObjects ["Land_NavigLight", _baseSize];
{ _x setLightFlareMaxDistance _lightViewDistance; } forEach _navLights;

///////////////////////////////////////////////////////////
// UAV
///////////////////////////////////////////////////////////
{
    _uav = missionNamespace getVariable _x;
    if !(isNil "_uav") then {
        { _uav removeWeaponGlobal getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon") } forEach getPylonMagazines _uav;
        _uav setPylonLoadOut [1, "PylonRack_Bomb_GBU12_x2", true, [0]];
        _uav setPylonLoadOut [2, "PylonRack_Bomb_SDB_x4", true, [0]];
        [_uav, false, 10, 0] call YAINA_VEH_fnc_initVehicle;
    };
} forEach ["UAV1", "UAV2"];

///////////////////////////////////////////////////////////
// REPAIR
///////////////////////////////////////////////////////////
{
    _x = missionNamespace getVariable _x;
    if !(isNil "_x") then {
        _x setVariable ["YAINA_VEH_Drivers", ["HQ", "MERT", "PILOT", "UAV"], true];
        [_x, {

            params ["_unit", "_pos", "_veh", "_turret"];

            if (isNil { _veh getVariable "YAINA_repair_action" }) then {

                // Repair actions, if cursorobject is within 10m then we can repair
                _actionID = _veh addAction ["Repair", {
                        params ["_target", "_caller", "_id"];

                        if (cursorObject isKindOf "UAV") then {
                            [cursorObject, 20, 10, false, 10] execVM "Scripts\YAINA\Service\uav.sqf";
                        } else {
                            ['AllVehicles', cursorObject, 20, 10, false, true, 10] execVM "Scripts\YAINA\Service\general.sqf";
                        };
                    },
                    [], 10, true, false, "",
                    "_f = _target getVariable 'YAINA_repair_action'; if !(isNil '_f') then { _target setUserActionText [_f, format['Repair %1', getText(configFile >> 'CfgVehicles' >> (typeOf cursorObject) >> 'displayName')]] }; (vehicle player) isEqualTo _target && cursorObject distance2D player < 10 && cursorObject isKindOf 'AllVehicles' && !(cursorObject isKindOf 'Man' || cursorObject isKindOf 'StaticWeapon')"
                ];
                _veh setVariable ["YAINA_repair_action", _actionID];
            };
        }] call YAINA_VEH_fnc_addGetInHandler;

        // We init vehicle last to ensure the handlers / vars are set to copy onto any respawned assets
        [_x, false, 10, 50, [], {
            params ["_veh", "_args"];
            _veh animate ['hideturret',1];
            _veh lockTurret [[0],TRUE];
            _veh removeWeaponTurret ["LMG_RCWS",[0]];
        }, [], true] call YAINA_VEH_fnc_initVehicle;
    };
} forEach ["REP1"];

///////////////////////////////////////////////////////////
// HELI / JET
///////////////////////////////////////////////////////////

{
    _x = missionNamespace getVariable _x;
    if !(isNil "_x") then {
        [_x] call YAINA_VEH_fnc_initHeli;
    };
} forEach ["HE1", "HE2", "HE3", "HE4", "HE5"];

if !(isNil "JET1") then {
    [JET1, false, 300, 1000, []] call YAINA_VEH_fnc_initVehicle;
};

///////////////////////////////////////////////////////////
// MEDEVAC
///////////////////////////////////////////////////////////

if !(isNil "TM") then {

    TM enableCopilot false;
    TM setVariable ["YAINA_VEH_Drivers", ["MERT"], true];
    TM setVariable ["MERT_QUAD_unloading", 0, true];


    ///////////////////////////////////////////////////////
    // ONLY UNCONSIOUS PLAYERS, PILOTS, OR MERT CAN GET IN
    ///////////////////////////////////////////////////////
    [TM, {
        params ["_unit", "_pos", "_veh", "_turret"];

        // We don't care about driver, as that's handled by the normal
        // vehicle functions, so only the other slots

        if (!(_pos isEqualTo "driver") &&
            { !(["MERT", "PILOT"] call YAINA_fnc_testTraits) } &&
            { !(player getVariable ["ais_unconscious", false]) } )  then {

            // Let them know
            "Only MERT or Unconscious players may board this chopper" call YFNC(hintC);

            moveOut player;
        };

    }] call YAINA_VEH_fnc_addGetInHandler;

    [TM, true, 10, 3000, [], {

        params ["_veh", "_args"];

        _internalQuad = "B_QuadBike_01_F" createVehicle [0,0,0];
        _internalQuad enableSimulationGlobal false;
        _internalQuad attachTo [_veh, [0,-1,0]];
        _veh setVariable ["MERT_QUAD_dummy", _internalQuad, true];

        ///////////////////////////////////////////////////////
        // REMOVE QUAD
        ///////////////////////////////////////////////////////

        _checkCode = "!(vehicle _this isEqualTo _target) &&
            { [['MERT'], _this] call YAINA_fnc_testTraits } &&
            { serverTime - (_target getVariable['MERT_QUAD_unloading', 0]) > 12 } &&
            { !(isObjectHidden (_target getVariable 'MERT_QUAD_dummy')) }";

        [_veh, {}, "<t color='#ff1111'>Unload Quadbike</t>", {
            params ["_target", "_caller", "_id", "_arguments"];

            // We set serverTime to now, in case of a DC whilst downloading, we
            // dont want the mission to bug out
            _target setVariable["MERT_QUAD_unloading", serverTime, true];

            ["Unloading Quad Bike", 10, {
                // Success, unpack quad
                params ["_target", "_caller", "_internalQuad"];

                _target setVariable["MERT_QUAD_unloading", 0, true];

                // Ensure we have no quad
                if(isNil {_target getVariable "MERT_QUAD_veh"} || { !(alive (_target getVariable "MERT_QUAD_veh")) } ) then {

                    _quad = "B_QuadBike_01_F" createVehicle (_target getRelPos [7, 180]);
                    _quad setDir (getDir _target);

                    // Only allow MERT to drive it...
                    _quad setVariable ["YAINA_VEH_Drivers", ["MERT"], true];
                    _target setVariable ["MERT_QUAD_veh", _quad, true];

                    // Vehicle Handler, this has a short despawn distance (200m)
                    [_quad, true, -1, 100, [], {
                        params ["_veh", "_args"];
                        (_args select 0) hideObjectGlobal true;
                    }, [_internalQuad], true, {
                        params ["_veh", "_args"];
                        _args params ["_internalQuad"];
                        if (!isNull _internalQuad) then { _internalQuad hideObjectGlobal false; };
                    }, [_internalQuad]] call YAINA_VEH_fnc_initVehicle;

                    // And the guy who deployed it takes the keys so it shows up on the map
                    [_quad, _caller] call YAINA_VEH_fnc_takeKey;
                } else {
                    systemChat "The quadbike has already been deployed..."
                };
            }, [_target, _caller, _arguments select 0], {
                // on Abort;
                params ["_target", "_caller", "_internalQuad"];
                _target setVariable["MERT_QUAD_unloading", 0, true];
            }] call AIS_Core_fnc_Progress_ShowBar;

        }, [_internalQuad], 6, false, true, "", _checkCode, 5, false] call YFNC(addActionMP);

        ///////////////////////////////////////////////////////
        // INSERT QUAD
        ///////////////////////////////////////////////////////

        _checkLoadCode = "!(vehicle _this isEqualTo _target) &&
            { serverTime - (_target getVariable['MERT_QUAD_loading', 0]) > 12 } &&
            { !(isNil { _target getVariable 'MERT_QUAD_veh' }) && { alive (_target getVariable 'MERT_QUAD_veh') } } &&
            { (_target getVariable 'MERT_QUAD_veh') distance2D _target < 10 }";

        [_veh, {}, "<t color='#ff1111'>Reload Quadbike</t>", {
            params ["_target", "_caller", "_id", "_arguments"];

            // We set serverTime to now, in case of a DC whilst downloading, we
            // dont want the mission to bug out
            _target setVariable["MERT_QUAD_loading", serverTime, true];

            ["Loading Quad Bike", 10, {
                // Success, unpack quad
                params ["_target", "_caller"];

                _target setVariable["MERT_QUAD_loading", 0, true];

                // Delete our quad
                deleteVehicle (_target getVariable "MERT_QUAD_veh");

                // Show the dummy
                [(_target getVariable "MERT_QUAD_dummy"), false] remoteExec ["hideObjectGlobal", 2];

            }, [_target, _caller], {
                // on Abort;
                params ["_target", "_caller"];
                _target setVariable["MERT_QUAD_loading", 0, true];
            }] call AIS_Core_fnc_Progress_ShowBar;

        }, [], 6, false, true, "", _checkLoadCode, 10, false] call YFNC(addActionMP);

        ///////////////////////////////////////////////////////
        // SELF DESTRUCT
        ///////////////////////////////////////////////////////


        // Only condition is that the requestor is MERT, and it's empty
        // and not already getting some explosives or in the base area
        _checkCode = "'MERT' call YAINA_fnc_testTraits &&
                      { !( [_target] call YAINA_fnc_inBaseProtectionArea ) } &&
                      { ( { alive _x } count (crew _target) ) isEqualTo 0 } &&
                      { isNil { _target getVariable 'YAINA_planting_explosives' } } &&
                      { isNil { _target getVariable 'YAINA_explosives' } }";

        [_veh, {}, "<t color='#ff1111'>Plant Explosives</t>", {
            params ["_target", "_caller", "_id", "_arguments"];

            // We set serverTime to now, in case of a DC whilst downloading, we
            // dont want the mission to bug out
            _target setVariable["YAINA_planting_explosives", true, true];

            ["Planting Explosives", 5, {

                params ["_target", "_caller"];
                _target setVariable["YAINA_explosives", true, true];
                _target setVariable["YAINA_planting_explosives", nil, true];

                // Let them know
                [_caller, "Explosives have been set for 30 seconds"] remoteExecCall ["sideChat"];

                // And start a timer to explode
                [30, getPos _target vectorAdd [0,1,0.5], [2,1,2], "Bo_mk82", {
                    params ["_target", "_caller"];
                    if !( ({ alive _x } count (crew _target) ) isEqualTo 0) exitWith {
                        // Abort.. not empty
                        _target setVariable["YAINA_explosives", nil, true];
                        [_caller, "Destruction Aborted, there are players on board"] remoteExecCall ["sideChat"];
                        false
                    };
                    true
                }, [_target, _caller]] remoteExec ["YAINA_MM_fnc_destroy", 2];

            }, [_target, _caller], {
                // on Abort;
                params ["_target", "_caller"];
                _target setVariable["YAINA_planting_explosives", nil, true];
            }] call AIS_Core_fnc_Progress_ShowBar;
        }, [], 1.5, false, true, "", _checkCode, 10, false] call YFNC(addActionMP);

    }, [], true, {
        // Respawn Code
        params ["_veh", "_args"];

        if !(isNull _veh) then {
            deleteVehicle (_veh getVariable "MERT_QUAD_dummy");
        };

    }] call YAINA_VEH_fnc_initVehicle;
};

///////////////////////////////////////////////////////////
// STATIC MEDICSTATIONS
///////////////////////////////////////////////////////////
{
    _x = missionNamespace getVariable _x;
    if !(isNil "_x") then {
        _x setVariable ["AIS_REQUIRE_MEDIKIT", false, true];
        _x setVariable ["AIS_NO_CONSUME_FAKS", true, true];
        [_x, 20] call AIS_Core_fnc_addMedicStation;
    };
} forEach ["MedicStation1"];

///////////////////////////////////////////////////////////
// AA Ammo
///////////////////////////////////////////////////////////

{ _x addEventHandler ["Fired", {(_this select 0) setvehicleammo 1}] } forEach AIR_DEFENCES;

///////////////////////////////////////////////////////////
// VEHICLES
///////////////////////////////////////////////////////////

{
    _x = missionNamespace getVariable _x;
    if !(isNil "_x") then {
        [_x, true, 10, 3000] call YAINA_VEH_fnc_initVehicle;
    };
} forEach ["VE1","VE2","VE3","VE4","VE5","VE6","VE7","BT1","BT2","BT3","BT4","BT5","BT6"];

///////////////////////////////////////////////////////////
// GENERAL SETUP FOR BOTH
///////////////////////////////////////////////////////////
private _mapInit = missionNamespace getVariable format["YAINA_INIT_fnc_%1", worldName];
if (!isNil "_mapInit") then { call _mapInit; };