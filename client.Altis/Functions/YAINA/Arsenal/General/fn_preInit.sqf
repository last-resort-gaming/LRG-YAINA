/*
Function: YAINA_ARSENAL_fnc_preInit

Description:
	Handles initialization of the arsenals during the preInit phase.
    The setup is mainly concerned with populating the restriction sets and variables.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h";

///////////////////////////////////////////////////////////
// GLOBAL BLACKLIST
///////////////////////////////////////////////////////////

// Blacklist of items that are removed from the player when
// they take them regardless if it's looting or exchanging
// backpacks with an enemy etc.

GVAR(globalBlacklist) = [
    "1Rnd_SmokeRed_Grenade_shell",
    "3Rnd_SmokeRed_Grenade_shell",
    "3Rnd_UGL_FlareRed_F",
    "Chemlight_red",
    "FlareRed_F",
    "SmokeShellRed",
    "UGL_FlareRed_F"
];

///////////////////////////////////////////////////////////
// HELPER
///////////////////////////////////////////////////////////

_addToArray = {
    params ["_array", "_key", "_value"];

    _idx = (_array select 0) find _key;
    if (_idx isEqualTo -1) then {
        (_array select 0) pushBack _key;
        (_array select 1) pushBack [_value];
    } else {
        ((_array select 1) select _idx) pushBack _value;
    };
};

GVAR(allItems) = [[],[]];

// Go through cfgWeapons, base classes only, and categorize items: we need class name, type (weapon/item), and suitable grouping
// Most info after a long and painful journy from BIS_fnc_itemType (though it refers to Binos as Items, when they are weapons
// At least from a cargo perspective

GVAR(weaponCargo)   = [[],[]];
GVAR(itemCargo)     = [[],[]];
GVAR(magazineCargo) = [[],[]];
GVAR(carryPacks)    = [[],[]];

///////////////////////////////////////////////////////////
// CfgWeapons
///////////////////////////////////////////////////////////
{
    _simulation = toLower getText (_x >> "simulation");
    _class      = configName _x;

    switch _simulation do {
        case "weapon": {
            _type = getNumber (_x >> "type");

            // Primary, Handgun, Launcher
            if (_type in [1,2,4]) exitWith {

                _type = getText (_x >> "cursor");

                // ACE modifies the cursor of some weapons during it's config, LRR/EBR/GM6 (from srifle => arifle)
                // https://github.com/acemod/ACE3/blob/master/addons/smallarms/CfgWeapons.hpp
                //
                // This makes the Lynx / LRR etc. available for regular joes in a normal setup of these restrictions.
                // So, to avoid this pain downstream in teh restrictions, we force it here where we don't want

                {
                    if (_class isKindOf [_x, configFile >> "CfgWeapons"]) exitWith { _type = "srifle"; };
                    nil
                } count ["EBR_base_F", "LRR_base_F", "GM6_base_F"];

                // Move the car-95 LSW under MG for now
                if  (_class isKindOf ["arifle_CTARS_base_F", configFile >> "CfgWeapons"]) then {
                    _type = "mg";
                };

                // However, suffix _gl for those with GL muzzles
                if (!({ _x in [ "EGLM", "GL_3GL_F" ] } count getArray(_x >> "muzzles") isEqualTo 0)) then {
                    _type = format["%1_gl", _type];
                };

                [GVAR(weaponCargo), _type, _class] call _addToArray;
            };
            if (_type isEqualTo 4096) exitWith {
                [GVAR(weaponCargo), "Laserdesignator", _class] call _addToArray;
            };
            if (_type isEqualTo 131072) exitWith {
                _infoType  = getNumber (_x >> "itemInfo" >> "type");
                _infoGroup = call {
                    if (_infoType isEqualTo 101) exitWith { "acc_muzzle" };
                    if (_infoType isEqualTo 201) exitWith {
                        // we just use optic_<TYPE> e.g optic_LPRS which handles all the groups
                        format ["optic_%1", (_class splitString "_") select 1];
                    };
                    if (_infoType isEqualTo 301) exitWith { "acc_pointer" };
                    if (_infoType isEqualTo 302) exitWith { "acc_bipod" };
                    if (_infoType isEqualTo 401) exitWith { "FirstAidKit" };
                    if (_infoType isEqualTo 605) exitWith {
                        // Group helmets by type, if they end with a side (_B _O etc. leave it)
                        _elems = _class splitString "_";
                        _group  = _elems select [0,2] joinString "_";
                        _suffix = _elems select (count _elems -1);
                        if (_suffix in ["B", "O", "I"]) then {
                            _group = format["%1_%2", _group, _suffix];
                        };
                        _group
                    };
                    if (_infoType isEqualTo 619) exitWith { "Medikit" };
                    if (_infoType isEqualTo 620) exitWith { "ToolKit" };
                    if (_infoType isEqualTo 621) exitWith { "UAVTerm" };
                    if (_infoType isEqualTo 701) exitWith {
                        // For vests, we just jump the first two elements unless it's a few we keep as class
                        _elems = _class splitString "_";
                        _group = _elems select [0,2] joinString "_";
                        if (_class in ["V_I_G_resistanceLeader_F", "V_EOD_IDAP_blue_F"]) then {
                            _group = _class;
                        };
                        _group;
                    };
                    if (_infoType isEqualTo 801) exitWith {
                        _elems = _class splitString "_";
                        _group = _elems select [0,2] joinString "_";
                        _group;
                    };
                };
                [GVAR(itemCargo), _infoGroup, _class] call _addToArray;
            };
        };
        case "binocular": {[GVAR(weaponCargo), _class, _class] call _addToArray;};
        case "nvgoggles": {
            // We group by type name (NVGoggles, NVGogglesB, O_NVGoggles)
            _elems = _class splitString "_";
            _group = _elems select 0;
            if (_elems select 0 isEqualTo "O") then { _group = _elems select [0,2] joinString "_"; };
            [GVAR(itemCargo), _group, _class] call _addToArray;
        };
        case "itemcompass": {[GVAR(itemCargo), _class, _class] call _addToArray;};
        case "itemgps": {[GVAR(itemCargo), _class, _class] call _addToArray;};
        case "itemmap": {[GVAR(itemCargo), _class, _class] call _addToArray;};
        case "itemminedetector": {[GVAR(weaponCargo), _class, _class] call _addToArray;};
        case "itemradio": {[GVAR(itemCargo), _class, _class] call _addToArray;};
        case "itemwatch": {[GVAR(itemCargo), _class, _class] call _addToArray;};
    };
    true;
} count ("getnumber (_x >> 'scope') isEqualTo 2 && (configName _x call BIS_fnc_baseWeapon) isEqualTo (configName _x)" configClasses (configfile >> 'CfgWeapons'));

///////////////////////////////////////////////////////////
// Eye Wear
///////////////////////////////////////////////////////////
{
    _class = configName _x;
    _elems = _class splitString "_";

    if !(_class isEqualTo "None") then {
        _type  = _elems select [0,2] joinString "_";

        if ((_elems select 1) in ["C", "B", "I", "O"]) then {
            _type = _class;
        };

        [GVAR(itemCargo), _type, _class] call _addToArray;
    };
    true;
} count ("getNumber (_x >> 'scope') >= 2" configClasses (configFile >> "CfgGlasses"));


///////////////////////////////////////////////////////////
// Backpacks, split on type, the mounts etc thrown into
// static
///////////////////////////////////////////////////////////

{
    _class = configName _x;

    _elems = _class splitString "_";
    _side  = _elems select 0;
    _type  = nil;

    // We split out UAV and Medical UAVs
    if(_elems select 1 in ["UAV", "IDAP"]) then {
        if (_elems select 3 isEqualTo "medical") then {
            _type = "MedicalUAV";
        } else {
            _type = "UAV";
        };
    } else {
        if (_class isKindOf "Weapon_Bag_Base") then {
        _type = "Static";
        } else {
        _type = _elems select 1;
        if(_type in ["HMG", "Mortar"]) then {
          _type = "Static";
        };

        };
    };
    _type = format["%1_%2", _side, _type];

    if (!isNil "_type") then {
        [GVAR(carryPacks), _type, _class] call _addToArray;
    };
    true;
} count ("getText (_x >> 'vehicleClass') isEqualTo 'Backpacks' AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configfile >> 'CfgVehicles'));

///////////////////////////////////////////////////////////
// Magazines
///////////////////////////////////////////////////////////

GVAR(magazineCargo) = [[],[]];

{
    _class = configName _x;
    _ammo  = toLower getText (configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _class >> "ammo") >> "simulation");

    _itemCategory = nil;
    _type = switch _ammo do {
        case "shotboundingmine": {_itemCategory = "Mine"; "MineBounding"};
        case "shotbullet": {"Bullet"};
        case "shotcm": {"CounterMeasures"};
        case "shotdeploy": {"Artillery"};
        case "shotdirectionalbomb": {_itemCategory = "Mine"; "MineDirectional"};
        case "shotgrenade": {"Grenade"};
        case "shotilluminating": {"Flare"};
        case "shotlaser": {"Laser"};
        case "shotmine": {_itemCategory = "Mine"; "MineLocal"};
        case "shotmissile": {"Missile"};
        case "shotrocket": {"Rocket"};
        case "shotshell": {"Shell"};
        case "shotsmoke";
        case "shotsmokex": {"SmokeShell"};
        case "shotspread": {"ShotgunShell"};
        case "shotsubmunitions": {"Artillery"};
        default { _class; };
    };

    [GVAR(magazineCargo), _type, _class] call _addToArray;

    if !(isNil "_itemCategory") then {
        [GVAR(magazineCargo), _itemCategory, _class] call _addToArray;
    };

    true;

} count ("!(getnumber (_x >> 'type') isEqualTo 0) AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> 'CfgMagazines'));