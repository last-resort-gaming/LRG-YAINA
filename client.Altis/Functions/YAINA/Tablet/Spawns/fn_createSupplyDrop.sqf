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
    ["_type", "B_CargoNet_01_ammo_F"]
];

if (_cargo isEqualTo []) exitWith {};

_cargo params ["_items", "_counts"];

if(isNil "_type") then { _type = "B_CargoNet_01_ammo_F"; };


// Check position is empty, or bail
if (triggerActivated SP_CARGO) exitWith { false; };

_crate = _type createVehicle getPosATL SP_CARGO;
_crate setDir (triggerArea SP_CARGO select 2);
_crate setVariable ["YAINA_ARSENAL_filtered", true, true];
_vehicle = false;

_attachable = true;
_droppable  = true;

// If a vehicle, we need to make a few changes
if (_type isKindOf "AllVehicles") then {
    _attachable = false;
    _droppable = false;
    _vehicle = true;

    // We only allow group leads to drive the vehicles
    [_crate, {
        params ["_unit", "_pos", "_veh", "_turret"];

        if (_pos isEqualTo "driver") then {
            if !(leader (group _unit) isEqualTo _unit) then {
                "Only group leaders may drive this vehicle" call YFNC(hintC);
                moveOut player;
            };
        };
    }] call YAINA_VEH_fnc_addGetInHandler;
};

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

// We don't respawn, but do give full functionality...
[_crate, _vehicle] call YAINA_VEH_fnc_initVehicle;

_crate