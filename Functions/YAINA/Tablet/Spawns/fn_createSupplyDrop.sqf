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
    [_crate, {
        params ["_crate", "_heli"];

        if ((position _crate) select 2 >= 50) then {

            _smoke1 = "SmokeShellGreen" createVehicle (position _crate);
            _smoke1 attachTo [_crate, [0,0,0.5]];

            // wait until we are 40m below chopper...
            [
                { !alive (_this select 1) or (_this select 0) distance (_this select 1) > 40 },
                {
                    params ["_heli", "_crate"];

                    if (alive _crate) then {
                        _chute1 = createVehicle ["B_parachute_02_F", [0,0,0], [], 0, 'FLY'];

                        _chute1 allowDamage false;
                        _chute1 disableCollisionWith _heli;

                        _chute1 setDir getDir _crate;
                        _chute1 setPos getPos _crate;

                        _crate attachTo [_chute1, [0,0,0]];

                        // When the crate gets to gound, clean up
                        [
                            { !alive (_this select 0) or (position (_this select 0)) select 2 < 1 },
                            {
                                private _crate = _this select 0;
                                detach _crate;
                                _chute setVelocity [0,0,0];
                                [ { deleteVehicle (_this select 0); }, [_this select 1], 4] call CBA_fnc_waitAndExecute;
                            },
                            [ _crate, _chute1 ]
                        ] call CBA_fnc_waitUntilAndExecute;
                    };
                },
                [ _heli, _crate ]
            ] call CBA_fnc_waitUntilAndExecute;
        };
    }] call YAINA_VEH_fnc_addRopeDetachHandler;
};