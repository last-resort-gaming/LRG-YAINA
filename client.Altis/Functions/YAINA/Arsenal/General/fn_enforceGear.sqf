/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h";

params ["_unit", ["_item", objNull], ["_container", objNull]];

private _allowedItems = GVAR(unitItems) + GVAR(unitBackpacks) + GVAR(unitWeapons) + GVAR(unitMags);

///////////////////////////////////////////////////////////
// Helper Functions
///////////////////////////////////////////////////////////

private _findCargo = {
    params ["_cargo", "_item"];
    !(({ !(_x find _item isEqualTo -1) } count (_cargo select 1)) isEqualTo 0);
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
        if !(_x isEqualTo "" || _x in _allowedItems) then {
            [_rem, _x] call _addToArray;
            [_x] call FNC(removeItem);
        };
        true;
    } count _contents;
    _rem;
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

    // What do we filter on, if it's a filtered container (i.e. blufor), we filter against
    // Our unit's entire permit/deny list, if it's not (i.e. looted from the enemy) we only
    // filter against the global blacklist

    if (_filteredContainer) then {
        // If it's not a valid item, replace it back into the container and say NO
        if ([GVAR(itemCargo),_item] call _findCargo) then {
            if !(_item in GVAR(unitItems)) then { [_item] call FNC(removeItem); _container addItemCargoGlobal [_item, 1];  }
            else {
                if (vest player isEqualTo _item)    then { [vestItems player] call _filterList; };
                if (uniform player isEqualTo _item) then { [uniformItems player] call _filterList; };
            };
        } else {
            if ([GVAR(weaponCargo),_item] call _findCargo) then {
                if !(_item in GVAR(unitWeapons)) then { [_item] call FNC(removeItem); _container addWeaponCargoGlobal [_item, 1];  };
            } else {
                if ([GVAR(magazineCargo),_item] call _findCargo) then {
                    if !(_item in GVAR(unitMags)) then { [_item] call FNC(removeItem); _container addMagazineCargoGlobal [_item, 1];  };
                } else {
                    if ([GVAR(carryPacks),_item] call _findCargo || [GVAR(specialPacks),_item] call _findCargo) then {
                        if !(_item in GVAR(unitBackpacks)) then {
                            [_item] call FNC(removeItem);
                            _container addBackpackCargoGlobal [_item, 1];
                        } else {
                            _rem = [backpackItems _unit] call _filterList;
                        };
                    };
                };
            };
        };
    } else {
        // Much the same function above, but checking inclusion rather than exclusion, again instead of creating a whole
        // new list of all valid items
        if ([GVAR(itemCargo),_item] call _findCargo) then {
            if (_item in GVAR(globalBlacklist)) then {
                [_item] call FNC(removeItem);
            } else {
                if (vest player isEqualTo _item)    then { [vestItems player]    call _filterBlacklist; };
                if (uniform player isEqualTo _item) then { [uniformItems player] call _filterBlacklist; };
            };
        } else {
            if ([GVAR(weaponCargo),_item] call _findCargo) then {
                if (_item in GVAR(globalBlacklist)) then { [_item] call FNC(removeItem); };
            } else {
                if ([GVAR(magazineCargo),_item] call _findCargo) then {
                    if (_item in GVAR(globalBlacklist)) then { [_item] call FNC(removeItem); };
                } else {
                    if ([GVAR(carryPacks),_item] call _findCargo || [GVAR(specialPacks),_item] call _findCargo) then {
                        if (_item in GVAR(globalBlacklist)) then {
                            [_item] call FNC(removeItem);
                        } else {
                            [backpackItems _unit] call _filterBlacklist;
                        };
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