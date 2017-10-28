/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h";

params ["_unit", ["_item", objNull], ["_container", objNull]];
private ["_allowedItems"];


private _getDN = {
    if(isClass (configFile >> "CfgWeapons"   >> _this)) exitWith { getText(configFile >> "CfgWeapons"   >> _this >> "displayName"); };
    if(isClass (configFile >> "CfgMagazines" >> _this)) exitWith { getText(configFile >> "CfgMagazines" >> _this >> "displayName"); };
    if(isClass (configFile >> "CfgVehicles"  >> _this)) exitWith { getText(configFile >> "CfgVehicles"  >> _this >> "displayName"); };
    if(isClass (configFile >> "CfgGoggles"   >> _this)) exitWith { getText(configFile >> "CfgGoggles"   >> _this >> "displayName"); };
    _this;
};

private _removedItemMessage = {
    params ["_item", "_from", "_itemClass"];
    private _dn = _item call _getDN;
    systemChat format ["Restricted Item: %1 removed from %2", _dn, _from];
};

private _findCargo = {
    params ["_cargo", "_item"];
    !(({ !(_x find _item isEqualTo -1) } count (_cargo select 1)) isEqualTo 0);
};

private _removeItem = {
    params ["_item", "_container"];

    // Have to check as item might be in multiple places
    if (_item isEqualTo primaryWeapon player)   then { player removeWeapon _item; [_item, "your hands"]  call _removedItemMessage; };
    if (_item isEqualTo secondaryWeapon player) then { player removeWeapon _item; [_item, "your hands"]  call _removedItemMessage; };
    if (_item isEqualTo handgunWeapon player)   then { player removeWeapon _item; [_item, "your hands"]  call _removedItemMessage; };
    if (_item isEqualTo binocular player)       then { player removeWeapon _item; [_item, "your person"] call _removedItemMessage; };

    // Weapon Items
    if (_item in primaryWeaponItems player)   then { player removePrimaryWeaponItem _item;   [_item, "your primary weapon"]   call _removedItemMessage; };
    if (_item in secondaryWeaponItems player) then { player removeSecondaryWeaponItem _item; [_item, "your secondary weapon"] call _removedItemMessage; };
    if (_item in handgunItems player)         then { player removeHandgunItem _item;         [_item, "your handgun"]          call _removedItemMessage; };

     // Auxilary Items
    if (_item in assignedItems player)    then { player unlinkItem _item;   [_item, "your person"] call _removedItemMessage; };
    if (_item isEqualTo goggles player)   then { player removeWeapon _item; [_item, "your head"]   call _removedItemMessage; };

    // Clothes / Items
    if (_item isEqualTo headgear player) then { removeHeadgear player; [_item, "your head"] call _removedItemMessage; };

    if (_item isEqualTo vest player) then {
        removeVest player;
        [_item, "your chest"] call _removedItemMessage;
    } else {
        if (_item in vestItems player) then {
            player removeItemFromVest _item;
            [_item, "your vest"] call _removedItemMessage;
        };
    };

    if (_item isEqualTo uniform player) then {
        removeUniform player;
        [_item, "your body"] call _removedItemMessage;
    } else {
        if (_item in uniformItems player) then {
            player removeItemFromUniform _item;
            [_item, "your uniform"] call _removedItemMessage;
        };
    };

    if (_item isEqualTo backpack player) then {
        removeBackpack player;
        [_item, "your back"] call _removedItemMessage;
    } else {
        if (_item in backpackItems player) then {
            player removeItemFromBackpack _item;
            [_item, "your backpack"] call _removedItemMessage;
        };
    };

};

if !(_unit isEqualTo player) exitWith {};

if (_item isEqualTo objNull) then {

    private _allowedItems = GVAR(unitItems) + GVAR(unitBackpacks) + GVAR(unitWeapons) + GVAR(unitMags);

    // Test weapons first, before attachemnts
    {
        if !(_x isEqualTo "" || _x in _allowedItems) then {
            _unit removeWeapon _x;
            [_x, "you", _x] call _removedItemMessage;
        } else {
            // Test Items
            if (_x isEqualTo primaryWeapon _unit) then {
                {
                    if !(_x isEqualTo "" || _x in _allowedItems) then {
                        _unit removePrimaryWeaponItem _x;
                        [_x, "your primary weapon", _x] call _removedItemMessage;
                    };
                    true;
                } count primaryWeaponItems _unit;
            };
            if (_x isEqualTo secondaryWeapon _unit) then {
                {
                    if !(_x isEqualTo "" || _x in _allowedItems) then {
                        _unit removeSecondaryWeaponItem _x;
                        [_x, "your secondary weapon", _x] call _removedItemMessage;
                    };
                    true;
                } count secondaryWeaponItems _unit;
            };
            if (_x isEqualTo handgunWeapon _unit) then {
                {
                    if !(_x isEqualTo "" || _x in _allowedItems) then {
                        _unit removeHandgunItem _x;
                        [_x, "your handgun", _x] call _removedItemMessage;
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
                [_x, "your uniform", _x] call _removedItemMessage;
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
                [_x, "your backpack", _x] call _removedItemMessage;
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
                [_x, "your backpack", _x] call _removedItemMessage;
            };
            true;
        } count backpackItems _unit
    };

    _headgear = headgear _unit;
    if !(_headgear isEqualTo "" || _headgear in _allowedItems) then {
        removeHeadgear _unit;
        [_headgear, "your head", _headgear] call _removedItemMessage;
    };

    _goggles = goggles _unit;
    if !(_goggles isEqualTo "" || _goggles in _allowedItems) then {
        removeGoggles _unit;
        [_headgear, "your face", _goggles] call _removedItemMessage;
    };

} else {

    if (_container isEqualTo objNull) exitWith {};

    // If it's not a valid item, replace it back into the container and say NO
    if ([GVAR(itemCargo),_item] call _findCargo) then {
        if !(_item in GVAR(unitItems)) then { [_item, _container] call _removeItem; _container addItemCargoGlobal [_item, 1];  };
    } else {
        if ([GVAR(weaponCargo),_item] call _findCargo) then {
            if !(_item in GVAR(unitWeapons)) then { [_item, _container] call _removeItem; _container addWeaponCargoGlobal [_item, 1];  };
        } else {
            if ([GVAR(magazineCargo),_item] call _findCargo) then {
                if !(_item in GVAR(unitMags)) then { [_item, _container] call _removeItem; _container addMagazineCargoGlobal [_item, 1];  };
            } else {
                if ([GVAR(carryPacks),_item] call _findCargo || [GVAR(specialPacks),_item] call _findCargo) then {
                    if !(_item in GVAR(backpackCargo)) then { [_item, _container] call _removeItem; _container addBackpackCargoGlobal [_item, 1]; };
                };
            };
        };
    };
};