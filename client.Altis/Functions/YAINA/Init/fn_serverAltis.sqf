/*
	author: Martin
	description: none
	returns: nothing
*/

///////////////////////////////////////////////////////////
// RUNWAY LIGHTING
///////////////////////////////////////////////////////////

// Ensure the airstrip lights are visible from afar (whole world)
_lightViewDistance = 2 * worldSize * sqrt 2;
_navLights         = getMarkerPos "BASE" nearObjects ["Land_NavigLight", 500];

{ _x setLightFlareMaxDistance _lightViewDistance; } forEach _navLights;

// And disable damage on them
{ _x allowDamage false; } forEach _navLights;

///////////////////////////////////////////////////////////
// UAV
///////////////////////////////////////////////////////////
{
    _uav = _x;
    { _uav removeWeaponGlobal getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon") } forEach getPylonMagazines _uav;
    _uav setPylonLoadOut [1, "PylonRack_Bomb_GBU12_x2", true, [0]];
    _uav setPylonLoadOut [2, "PylonRack_Bomb_GBU12_x2", true, [0]];
    [_uav, false, 10, 0] call YAINA_VEH_fnc_initVehicle;
} forEach [UAV1, UAV2];

_uav = UAV3;
{ _uav removeWeaponGlobal getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon") } forEach getPylonMagazines _uav;
{ _uav animate [_x, 1, true]; } forEach getArray (configFile >> "CfgVehicles" >> "B_UAV_05_F" >> "AircraftAutomatedSystems" >> "wingFoldAnimations");
_uav setPylonLoadOut [1, "PylonMissile_1Rnd_BombCluster_01_F", true, [0]];
_uav setPylonLoadOut [2, "PylonRack_Bomb_GBU12_x2", true, [0]];
[_uav, false, 10, 0] call YAINA_VEH_fnc_initVehicle;

///////////////////////////////////////////////////////////
// REPAIR
///////////////////////////////////////////////////////////
{
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
    [_x, false, 10, 0] call YAINA_VEH_fnc_initVehicle;
} forEach [REP1];

///////////////////////////////////////////////////////////
// HELI / JET
///////////////////////////////////////////////////////////

{
    [_x, false, 10, 1000] call YAINA_VEH_fnc_initVehicle;
} forEach [HE1, HE2, HE3, HE4, HE5];

[JET1, false, 300, 1000, []] call YAINA_VEH_fnc_initVehicle;

///////////////////////////////////////////////////////////
// MEDEVAC
///////////////////////////////////////////////////////////

TM setVariable ["YAINA_VEH_Drivers", ["PILOT", "MERT"], true];
[TM, false, 10, 1000, []] call YAINA_VEH_fnc_initVehicle;


///////////////////////////////////////////////////////////
// VEHICLES
///////////////////////////////////////////////////////////

{
    [_x, true, 10, 1000] call YAINA_VEH_fnc_initVehicle;
} forEach [VE1,VE2,VE3];

///////////////////////////////////////////////////////////
// GENERAL SETUP FOR BOTH
///////////////////////////////////////////////////////////
private _mapInit = missionNamespace getVariable format["YAINA_INIT_fnc_%1", worldName];
if (!isNil "_mapInit") then { call _mapInit; };