/*
  Player Changed: Called from ammobox creator when
  the player selection in the list is changed.

  This then populates the ammo selection available.
*/
#include "..\defines.h"

params ["_lb", "_idx"];
private ["_unit", "_loadout", "_mags"];

// UI updates...
disableSerialization;

private _icons = [
    [
        "iconMan", "iconManMedic",
        "iconManEngineer", "iconManExplosive",
        "iconManRecon", "iconManVirtual",
        "iconManAT", "iconManLeader",
        "iconManMG", "iconManOfficer"
    ],
    [
        "\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa", "\A3\ui_f\data\map\vehicleicons\iconManMedic_ca.paa",
        "\A3\ui_f\data\map\vehicleicons\iconManEngineer_ca.paa", "\A3\ui_f\data\map\vehicleicons\iconManExplosive_ca.paa",
        "\A3\ui_f\data\map\vehicleicons\iconManRecon_ca.paa", "\A3\ui_f\data\map\vehicleicons\iconManVirtual_ca.paa",
        "\A3\ui_f\data\map\vehicleicons\iconManAT_ca.paa", "\A3\ui_f\data\map\vehicleicons\iconManLeader_ca.paa",
        "\A3\ui_f\data\map\vehicleicons\iconManMG_ca.paa", "\A3\ui_f\data\map\vehicleicons\iconManOfficer_ca.paa"
    ]
];

// Set the newly selected user, and ensure we are on the user-loadout button...
if (_idx isEqualTo -1) exitWith {};

// Update, and ensure we are selected on menu
GVAR(loadout_last_idx) = _idx;
[(ctrlParent _lb) displayCtrl 30, false] call FNC(clickLoadoutButton);

_unit = missionNamespace getVariable ( _lb lbData _idx );

// Find the selected player class icon and update the loadout button icon

_iconName = getText(configFile >> "cfgVehicles" >> (typeOf _unit) >> "icon");
if(isNil "_iconName") then {
  _iconName = "iconMan";
};

_idx = (_icons select 0) find _iconName;
if (_idx isEqualTo -1) then { _idx = 0; };
_icon = (_icons select 1) select _idx;

_loadout = getUnitLoadout _unit;
_ctrl    = ctrlParent _lb;

(_ctrl displayCtrl 30) ctrlSetText _icon;

// If i have a primary, get primary mags
_mags = [];

// Primary
{ _mags pushBackUnique (configFile >> "cfgMagazines" >> _x) } forEach (
    (configFile >> "CfgWeapons" >> ((_loadout select 0) select 0) >> "magazines") call BIS_fnc_getCfgData);

// Secondary
{ _mags pushBackUnique (configFile >> "cfgMagazines" >> _x) } forEach (
    (configFile >> "CfgWeapons" >> ((_loadout select 1) select 0) >> "magazines") call BIS_fnc_getCfgData);

// Side Arm
{ _mags pushBackUnique (configFile >> "cfgMagazines" >> _x) } forEach (
    (configFile >> "CfgWeapons" >> ((_loadout select 2) select 0) >> "magazines") call BIS_fnc_getCfgData);

[_mags] call FNC(populateLoadout);
