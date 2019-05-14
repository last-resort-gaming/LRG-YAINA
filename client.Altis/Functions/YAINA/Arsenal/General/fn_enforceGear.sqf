/*
Function: YAINA_ARSENAL_fnc_enforceGear

Description:


Parameters:
	_unit - The unit/player which to enforce gear for [Object]
    _item - The item to check gear restrictions for [Object, defaults to null]
    _container - If applicable, the container from which the item was taken [Object, defaults to null]

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h";

params ["_unit", ["_item", objNull], ["_container", objNull]];

private _allowedItems = GVAR(unitItems) + GVAR(unitBackpacks) + GVAR(unitWeapons) + GVAR(unitMags);

///////////////////////////////////////////////////////////
// Helper Functions
///////////////////////////////////////////////////////////

private _findCargo = {
    params ["_cargo", "_items"];

    _found = false;

    {
      _cargoItems = _x;
      {
        if (_x in _cargoItems) exitWith { _found = true; };
        nil
      } count _items;
      if (_found) exitWith {};
      nil
    } count (_cargo select 1);

    _found
};

private _addToArray = {
    params ["_array", "_key"];

    _idx = (_array select 0) find _key;
    if (_idx isEqualTo -1) then {
        (_array select 0) pushBack _key;
        (_array select 1) pushBack 1;
    } else {
        (_array select 1) set [_idx, (_array select 1 select _idx) + 1];
    };
};

private _filterList = {
    params ["_contents"];
    private _rem = [[],[]];
    {
        if !(_x isEqualTo "" || { _x in _allowedItems } ) then {
            // Just do a quick check of parent here
            _p = _x call _getParent;
            if !( !(isNil "_p") && { _p in _allowedItems }) then {
                [_rem, _x] call _addToArray;
                [_x] call FNC(removeItem);
            };
        };
        true;
    } count _contents;
    _rem;
};

private _itemsInArray = {
    params ["_items", "_list"];
    _found = false;
    {
        if (_x in _list) exitWith { _found = true; };
        nil;
    } count _items;
    _found;
};

private _filterBlacklist = {
    params ["_contents"];
    private _rem = [[],[]];
    {
        if (_x in GVAR(globalBlacklist)) then {
            [_rem, _x] call _addToArray;
            [_x] call FNC(removeItem);
        };
        true;
    } count _contents;
    _rem;
};

private _getParent = {

    // So we start by using BIS_fnc_base{Vehicle,Weapon}, we cant just use inheritsFrom due
    // to blacklisted NVGogglesB_blk_F (ENVG-II) decending from our permitted NVGoggles
    if (isClass (configFile >> "CfgWeapons"  >> _this)) exitWith {
        // However, that's not enough as TFAR doesn't set base parameters, but instead uses tf_parent
        // So if that exists, we use that as our primary, interestingly, this only applies to SW radios
        if (isText (configFile >> "CfgWeapons" >> _this >> "tf_parent")) exitWith {
            getText (configFile >> "CfgWeapons" >> _this >> "tf_parent");
        };
        _this call BIS_fnc_baseWeapon;
    };
    if (isClass (configFile >> "CfgVehicles" >> _this)) exitWith { _this call BIS_fnc_baseVehicle };
    nil
};

/*
[
  "tf_anprc152_350" call _getParent,
  "NVGogglesB_blk_F" call _getParent,
  "B_Kitbag_rgr_AAR" call _getParent,
  "dummy" call _getParent
]
returns: ["tf_anprc152","NVGogglesB_blk_F","B_Kitbag_rgr",any]
*/

///////////////////////////////////////////////////////////
// Main
///////////////////////////////////////////////////////////

if !(_unit isEqualTo player) exitWith {};

if (_item isEqualTo objNull) then {

    // Just loop all items on our person and let remove item take care of it
    [(
        [
            primaryWeapon _unit,
            handgunWeapon _unit,
            secondaryWeapon _unit,
            uniform _unit,
            vest _unit,
            backpack _unit,
            headgear _unit,
            goggles _unit
        ]
        + primaryWeaponItems _unit
        + handgunItems _unit
        + secondaryWeaponItems _unit
        + uniformItems _unit
        + vestItems _unit
        + backpackItems _unit
        + (assignedItems player)
    )] call _filterList;

} else {

    if (_container isEqualTo objNull) exitWith {};

    private _inBase = !(({ player inArea _x } count BASE_PROTECTION_AREAS) isEqualTo 0);
    private _filteredContainer = _inBase || { _container getVariable [QVAR(filtered), false] };

    // Due to some rather unfortunate cases, such as TFAR substituting items on channel change (e.g: "tf_anprc152_123")
    // or backpack loadouts on EN for say: "B_Kitbag_rgr_AAR", we need to find out the parent arsenal item that
    // may exist in the allowedItems array.

    _items = [_item];

    _parent = _item call _getParent;
    if !(isNil "_parent") then {
        _items pushBack _parent;
    };

    // What do we filter on, if it's a filtered container (i.e. blufor), we filter against
    // Our unit's entire permit/deny list, if it's not (i.e. looted from the enemy) we only
    // filter against the global blacklist

    if (_filteredContainer) then {
        // If it's not a valid item, replace it back into the container and say NO
        if ([GVAR(itemCargo), _items] call _findCargo) then {
            if !([_items, GVAR(unitItems)] call _itemsInArray) then { [_item] call FNC(removeItem); _container addItemCargoGlobal [_item, 1];  }
            else {
                if (vest player isEqualTo _item)    then { [vestItems player] call _filterList; };
                if (uniform player isEqualTo _item) then { [uniformItems player] call _filterList; };
            };
        } else {
            if ([GVAR(weaponCargo), _items] call _findCargo) then {
                if !([_items, GVAR(unitWeapons)] call _itemsInArray) then { [_item] call FNC(removeItem); _container addWeaponCargoGlobal [_item, 1];  };
            } else {
                if ([GVAR(magazineCargo), _items] call _findCargo) then {
                    if !(_item in GVAR(unitMags)) then { [_item] call FNC(removeItem); _container addMagazineCargoGlobal [_item, 1];  };
                } else {
                    if ([GVAR(carryPacks), _items] call _findCargo) then {
                        if !([_items, GVAR(unitBackpacks)] call _itemsInArray) then {
                            [_item] call FNC(removeItem);
                            _container addBackpackCargoGlobal [_item, 1];
                        } else {
                            _rem = [backpackItems _unit] call _filterList;
                        };
                    } else {
                        [format["player: %1, item: %2, filtered: true, msg: not found in cargo lists", name player, _item], "ArsenalLog"] remoteExec [QYFNC(log), 2];
                    };
                };
            };
        };
    } else {
        // Much the same function above, but checking inclusion rather than exclusion, again instead of creating a whole
        // new list of all valid items
        if ([GVAR(itemCargo), _items] call _findCargo) then {
            if ([_items, GVAR(globalBlacklist)] call _itemsInArray) then {
                [_item] call FNC(removeItem);
            } else {
                if (vest player isEqualTo _item)    then { [vestItems player]    call _filterBlacklist; };
                if (uniform player isEqualTo _item) then { [uniformItems player] call _filterBlacklist; };
            };
        } else {
            if ([GVAR(weaponCargo), _items] call _findCargo) then {
                if ([_items, GVAR(globalBlacklist)] call _itemsInArray) then { [_item] call FNC(removeItem); };
            } else {
                if ([GVAR(magazineCargo), _items] call _findCargo) then {
                    if ([_items, GVAR(globalBlacklist)] call _itemsInArray) then { [_item] call FNC(removeItem); };
                } else {
                    if ([GVAR(carryPacks), _items] call _findCargo) then {
                        if ([_items, GVAR(globalBlacklist)] call _itemsInArray) then {
                            [_item] call FNC(removeItem);
                        } else {
                            [backpackItems _unit] call _filterBlacklist;
                        };
                    } else {
                        [format["player: %1, item: %2, filtered: false, msg: not found in cargo lists", name player, _item], "ArsenalLog"] remoteExec [QYFNC(log), 2];
                    };
                };
            };
        };
    };
};

///////////////////////////////////////////////////////////
// OTHER MODULES CARE TOO
///////////////////////////////////////////////////////////

call YAINA_UAV_fnc_rescan;