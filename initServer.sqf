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


// Setup Medivac
MedivacChopper setObjectTextureGlobal [0, "Data\Skins\H-9M_co.paa"];
MedivacChopper setVariable ["YAINA_MERT", true, true];
[MedivacChopper, true, 5, 1000, ["YAINA_MERT"]] call YAINA_VEH_fnc_initVehicle;