/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h";

params ["_unit", ["_item", objNull], ["_container", objNull]];

private _removedItemMessage = {
    params ["_item", "_from", "_itemClass"];
    _msg = format ["Restricted Item: %1 removed from %2", _item, _from];
    systemChat _msg;
    diag_log _msg;
};

private _getDN = {
    if(isClass (configFile >> "CfgWeapons"   >> _x)) exitWith { getText(configFile >> "CfgWeapons"   >> _x >> "displayName"); };
    if(isClass (configFile >> "CfgMagazines" >> _x)) exitWith { getText(configFile >> "CfgMagazines" >> _x >> "displayName"); };
    if(isClass (configFile >> "CfgVehicles"  >> _x)) exitWith { getText(configFile >> "CfgVehicles"  >> _x >> "displayName"); };
    _x;
};

if !(_unit isEqualTo player) exitWith {};

if (_item isEqualTo objNull) then {

    _allowedItems = GVAR(unitItems) + GVAR(unitBackpacks) + GVAR(unitWeapons) + GVAR(unitMags);

    // Test weapons first, before attachemnts
    {
        if !(_x isEqualTo "" || _x in _allowedItems) then {
            _unit removeWeapon _x;
            [_x call _getDN, "you", _x] call _removedItemMessage;
        } else {
            // Test Items
            if (_x isEqualTo primaryWeapon _unit) then {
                {
                    if !(_x isEqualTo "" || _x in _allowedItems) then {
                        _unit removePrimaryWeaponItem _x;
                        [_x call _getDN, "your primary weapon", _x] call _removedItemMessage;
                    };
                    true;
                } count primaryWeaponItems _unit;
            };
            if (_x isEqualTo secondaryWeapon _unit) then {
                {
                    if !(_x isEqualTo "" || _x in _allowedItems) then {
                        _unit removeSecondaryWeaponItem _x;
                        [_x call _getDN, "your secondary weapon", _x] call _removedItemMessage;
                    };
                    true;
                } count secondaryWeaponItems _unit;
            };
            if (_x isEqualTo handgunWeapon _unit) then {
                {
                    if !(_x isEqualTo "" || _x in _allowedItems) then {
                        _unit removeHandgunItem _x;
                        [_x call _getDN, "your handgun", _x] call _removedItemMessage;
                    };
                    true;
                } count handgunItems _unit;
            };
        };
        true;
    } count [primaryWeapon _unit, handgunWeapon _unit, secondaryWeapon _unit];

    // Now it's just backpack/uniform/vest items

    _uniform = uniform _unit;
    if !(_uniform isEqualTo "" || _uniform in _allowedItems) then {
        removeUniform _unit;
        [getText (configFile >> "CfgWeapons" >> _uniform >> "displayName"), "your body", _uniform] call _removedItemMessage;
    } else {
        // Uniform Cargo
        {
            if !(_x in _allowedItems) then {
                _unit removeItemFromUniform _x;
                [_x call _getDN, "your uniform", _x] call _removedItemMessage;
            };
            true;
        } count uniformItems _unit
    };

    _vest = vest _unit;
    if !(_vest isEqualTo "" || _vest in _allowedItems) then {
        removeVest _unit;
        [getText (configFile >> "CfgWeapons" >> _vest >> "displayName"), "your chest", _vest] call _removedItemMessage;
    } else {
        // Vest Cargo
        {
            if !(_x in _allowedItems) then {
                _unit removeItemFromVest _x;
                [_x call _getDN, "your backpack", _x] call _removedItemMessage;
            };
            true;
        } count vestItems _unit
    };

    _bp  = backpack _unit;
    if !(_bp isEqualTo "" || _bp in _allowedItems) then {
        removeBackpack _unit;
        [getText (configFile >> "CfgVehicles" >> _bp >> "displayName"), "your back", _bp] call _removedItemMessage;
    } else {
        // Backpack Cargo
        {
            if !(_x in _allowedItems) then {
                _unit removeItemFromBackpack _x;
                [_x call _getDN, "your backpack", _x] call _removedItemMessage;
            };
            true;
        } count backpackItems _unit
    };

    _headgear = headgear _unit;
    if !(_headgear isEqualTo "" || _headgear in _allowedItems) then {
        removeHeadgear _unit;
        [getText (configFile >> "CfgWeapons" >> _headgear >> "displayName"), "your head", _headgear] call _removedItemMessage;
    };

    _goggles = goggles _unit;
    if !(_goggles isEqualTo "" || _goggles in _allowedItems) then {
        removeGoggles _unit;
        [getText (configFile >> "CfgGoggles" >> _goggles >> "displayName"), "your face", _goggles] call _removedItemMessage;
    };

};