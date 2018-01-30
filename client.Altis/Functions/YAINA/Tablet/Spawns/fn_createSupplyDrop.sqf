/*
	author: MartinCo
	description:
	    Creates a list of items from the selected loadout
	    and passes it to the create ammo drop script.
    returns:
        The ammo drop created
*/

#include "..\defines.h"

params [
    ["_cargo", []],
    ["_type", "B_CargoNet_01_ammo_F"],
    ["_attachable", true],
    ["_droppable", false]
];

if (_cargo isEqualTo []) exitWith {};

_cargo params ["_items", "_counts"];

if(isNil "_type") then { _type = "B_CargoNet_01_ammo_F"; };

// Check position is empty, or bail
if (triggerActivated SP_CARGO) exitWith { false; };

_crate = _type createVehicle getPosATL SP_CARGO;
_crate setDir (triggerArea SP_CARGO select 2);
_crate setVariable ["YAINA_ARSENAL_filtered", true, true];

if (_attachable) then {
  _crate enableRopeAttach true;
};

// Empty default cargo
clearWeaponCargoGlobal _crate;
clearMagazineCargoGlobal _crate;
clearItemCargoGlobal _crate;
clearBackpackCargoGlobal _crate;

// Populate with selected items
for "_x" from 0 to ((count _items) - 1) do {
    // Find what kind of cargo item is, thankfully we can throw everything except
    // backpacks in as ItemCargo

    if ( isClass(configFile >> "CfgVehicles" >> (_items select _x)) ) then {
        _crate addBackpackCargoGlobal  [_items select _x, _counts select _x];
    } else {
        // Item Cargo works for any CfgWeapons items
        _crate addItemCargoGlobal [_items select _x, _counts select _x];
    };
};

// If we are droppable, we need to setup drop ropes...
if(_droppable) then {
    [_crate] call FNC(setDroppable);
};

// Add to zeeus
[[_crate]] call YFNC(addEditableObjects);

_crate