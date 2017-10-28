/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_itemClass"];

private _getDN = {
    if(isClass (configFile >> "CfgWeapons"   >> _this)) exitWith { getText(configFile >> "CfgWeapons"   >> _this >> "displayName"); };
    if(isClass (configFile >> "CfgMagazines" >> _this)) exitWith { getText(configFile >> "CfgMagazines" >> _this >> "displayName"); };
    if(isClass (configFile >> "CfgVehicles"  >> _this)) exitWith { getText(configFile >> "CfgVehicles"  >> _this >> "displayName"); };
    if(isClass (configFile >> "CfgGoggles"   >> _this)) exitWith { getText(configFile >> "CfgGoggles"   >> _this >> "displayName"); };
    _this;
};

private _removedItemMessage = {
    params ["_itemClass", "_from", "_itemClassClass"];
    private _dn = _itemClass call _getDN;
    systemChat format ["Restricted Item: %1 removed from %2", _dn, _from];
};

// Have to check as item might be in multiple places
if (_itemClass isEqualTo primaryWeapon player)   then { player removeWeapon _itemClass; [_itemClass, "your hands"]  call _removedItemMessage; };
if (_itemClass isEqualTo secondaryWeapon player) then { player removeWeapon _itemClass; [_itemClass, "your hands"]  call _removedItemMessage; };
if (_itemClass isEqualTo handgunWeapon player)   then { player removeWeapon _itemClass; [_itemClass, "your hands"]  call _removedItemMessage; };
if (_itemClass isEqualTo binocular player)       then { player removeWeapon _itemClass; [_itemClass, "your person"] call _removedItemMessage; };

// Weapon Items
if (_itemClass in primaryWeaponItems player)   then { player removePrimaryWeaponItem _itemClass;   [_itemClass, "your primary weapon"]   call _removedItemMessage; };
if (_itemClass in secondaryWeaponItems player) then { player removeSecondaryWeaponItem _itemClass; [_itemClass, "your secondary weapon"] call _removedItemMessage; };
if (_itemClass in handgunItems player)         then { player removeHandgunItem _itemClass;         [_itemClass, "your handgun"]          call _removedItemMessage; };

 // Auxilary Items
if (_itemClass in assignedItems player)    then { player unlinkItem _itemClass;   [_itemClass, "your person"] call _removedItemMessage; };
if (_itemClass isEqualTo goggles player)   then { player removeWeapon _itemClass; [_itemClass, "your head"]   call _removedItemMessage; };

// Clothes / Items
if (_itemClass isEqualTo headgear player) then { removeHeadgear player; [_itemClass, "your head"] call _removedItemMessage; };

if (_itemClass isEqualTo vest player) then {
    removeVest player;
    [_itemClass, "your chest"] call _removedItemMessage;
} else {
    if (_itemClass in vestItems player) then {
        player removeItemFromVest _itemClass;
        [_itemClass, "your vest"] call _removedItemMessage;
    };
};

if (_itemClass isEqualTo uniform player) then {
    removeUniform player;
    [_itemClass, "your body"] call _removedItemMessage;
} else {
    if (_itemClass in uniformItems player) then {
        player removeItemFromUniform _itemClass;
        [_itemClass, "your uniform"] call _removedItemMessage;
    };
};

if (_itemClass isEqualTo backpack player) then {
    removeBackpack player;
    [_itemClass, "your back"] call _removedItemMessage;
} else {
    if (_itemClass in backpackItems player) then {
        player removeItemFromBackpack _itemClass;
        [_itemClass, "your backpack"] call _removedItemMessage;
    };
};

