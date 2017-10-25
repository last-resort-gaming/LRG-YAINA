/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h";

params ["_unit", ["_item", objNull], ["_container", objNull]];

systemChat "Enforce Gear Called";

private _removedItemMessage = {
    params ["_item", "_from", "_itemClass"];
    _msg = format ["Removed restricted item: %1 (%3) from %2", _item, _from, _itemClass];
    systemChat _msg;
    diag_log _msg;
};

if !(_unit isEqualTo player) exitWith {};

if (_item isEqualTo objNull) then {

    // Test weapons first, before attachemnts
    {
        if !(_x isEqualTo "" || _x in GVAR(unitWeapons)) then {
            _unit removeWeapon _x;
            [getText (configFile >> "CfgWeapons" >> _x >> "displayName"), "you", _x] call _removedItemMessage;
        } else {
            // Test Items
            if (_x isEqualTo primaryWeapon _unit) then {
                {
                    if !(_x isEqualTo "" || _x in GVAR(unitItems)) then {
                        _unit removePrimaryWeaponItem _x;
                        [getText (configFile >> "CfgWeapons" >> _x >> "displayName"), "your primary weapon", _x] call _removedItemMessage;
                    };
                    true;
                } count primaryWeaponItems _unit;
            };
            if (_x isEqualTo secondaryWeapon _unit) then {
                {
                    if !(_x isEqualTo "" || _x in GVAR(unitItems)) then {
                        _unit removeSecondaryWeaponItem _x;
                        [getText (configFile >> "CfgWeapons" >> _x >> "displayName"), "your secondary weapon", _x] call _removedItemMessage;
                    };
                    true;
                } count secondaryWeaponItems _unit;
            };
            if (_x isEqualTo handgunWeapon _unit) then {
                {
                    if !(_x isEqualTo "" || _x in GVAR(unitItems)) then {
                        _unit removeHandgunItem _x;
                        [getText (configFile >> "CfgWeapons" >> _x >> "displayName"), "your handgun", _x] call _removedItemMessage;
                    };
                    true;
                } count handgunItems _unit;
            };
        };
        true;
    } count [primaryWeapon _unit, handgunWeapon _unit, secondaryWeapon _unit];

    // Now it's just backpack/uniform/vest items

    _uniform = uniform _unit;
    if !(_uniform isEqualTo "" || _uniform in GVAR(unitItems)) then {
        removeUniform _unit;
        [getText (configFile >> "CfgWeapons" >> _uniform >> "displayName"), "your body", _uniform] call _removedItemMessage;
    } else {
        // Uniform Cargo
        {
            if !(_x in GVAR(unitItems)) then {
                _unit removeItemFromUniform _x;
                [getText (configFile >> "CfgWeapons" >> _x >> "displayName"), "your uniform", _x] call _removedItemMessage;
            };
            true;
        } count uniformItems _unit
    };

    _vest = vest _unit;
    if !(_vest isEqualTo "" || _vest in GVAR(unitItems)) then {
        removeVest _unit;
        [getText (configFile >> "CfgWeapons" >> _vest >> "displayName"), "your chest", _vest] call _removedItemMessage;
    } else {
        // Vest Cargo
        {
            if !(_x in GVAR(unitItems)) then {
                _unit removeItemFromVest _x;
                [getText (configFile >> "CfgWeapons" >> _x >> "displayName"), "your backpack", _x] call _removedItemMessage;
            };
            true;
        } count vestItems _unit
    };

    _bp  = backpack _unit;
    if !(_bp isEqualTo "" || _bp in GVAR(unitBackpacks)) then {
        removeBackpack _unit;
        [getText (configFile >> "CfgVehicles" >> _bp >> "displayName"), "your back", _bp] call _removedItemMessage;
    } else {
        // Backpack Cargo
        {
            if !(_x in GVAR(unitItems)) then {
                _unit removeItemFromBackpack _x;
                [getText (configFile >> "CfgWeapons" >> _x >> "displayName"), "your backpack", _x] call _removedItemMessage;
            };
            true;
        } count backpackItems _unit
    };

    _headgear = headgear _unit;
    if !(_headgear isEqualTo "" || _headgear in GVAR(unitItems)) then {
        removeHeadgear _unit;
        [getText (configFile >> "CfgWeapons" >> _headgear >> "displayName"), "your head", _headgear] call _removedItemMessage;
    };

    _goggles = goggles _unit;
    if !(_goggles isEqualTo "" || _goggles in GVAR(unitItems)) then {
        removeGoggles _unit;
        [getText (configFile >> "CfgGoggles" >> _goggles >> "displayName"), "your face", _goggles] call _removedItemMessage;
    };

};