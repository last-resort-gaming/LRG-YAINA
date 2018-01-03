/*
	author: Martin
	description: none
	returns: nothing
*/


// Dyanmic Groups
["Initialize"] call BIS_fnc_dynamicGroups;

// Setup some Global Vars
CBA_display_ingame_warnings = false;
publicVariable "CBA_display_ingame_warnings";

// Bring in UAVs

_uav = "B_UAV_02_dynamicLoadout_F" createVehicle [0,0,0];
{ _uav removeWeaponGlobal getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon") } forEach getPylonMagazines _uav;
_uav setPylonLoadOut [1, "PylonRack_Bomb_GBU12_x2", true, [0]];
_uav setPylonLoadOut [2, "PylonRack_Bomb_GBU12_x2", true, [0]];
_uav setDir (getDir hangar1);
_uav setPosATL (getPosATL hangar1);
createVehicleCrew _uav;
[_uav, false, 10, 0] call YAINA_VEH_fnc_initVehicle;

_uav = "B_UAV_02_dynamicLoadout_F" createVehicle [0,0,0];
{ _uav removeWeaponGlobal getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon") } forEach getPylonMagazines _uav;
_uav setPylonLoadOut [1, "PylonRack_Bomb_GBU12_x2", true, [0]];
_uav setPylonLoadOut [2, "PylonRack_Bomb_GBU12_x2", true, [0]];
_uav setDir (getDir hangar2);
_uav setPosATL (getPosATL hangar2);
createVehicleCrew _uav;
[_uav, false, 10, 0] call YAINA_VEH_fnc_initVehicle;

_uav = "B_UAV_05_F" createVehicle [0,0,0];
{ _uav removeWeaponGlobal getText (configFile >> "CfgMagazines" >> _x >> "pylonWeapon") } forEach getPylonMagazines _uav;
{ _uav animate [_x, 1, true]; } forEach getArray (configFile >> "CfgVehicles" >> "B_UAV_05_F" >> "AircraftAutomatedSystems" >> "wingFoldAnimations");
_uav setPylonLoadOut [1, "PylonMissile_1Rnd_BombCluster_01_F", true, [0]];
_uav setPylonLoadOut [2, "PylonRack_Bomb_GBU12_x2", true, [0]];
_uav setDir (getDir hangar3);
_uav setPosATL (getPosATL hangar3);
createVehicleCrew _uav;
[_uav, false, 10, 0] call YAINA_VEH_fnc_initVehicle;

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
} forEach [
    HEMTT_Repair1,
    HEMTT_Repair2
];

// Setup Medivac
MedivacChopper setObjectTextureGlobal [0, "Data\Skins\H-9M_co.paa"];
MedivacChopper setVariable ["YAINA_VEH_Drivers", ["PILOT", "MERT"], true];
[MedivacChopper, true, 5, 1000, []] call YAINA_VEH_fnc_initVehicle;