/*
	author: MartinCo
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_veh", ["_hasKeys", true],  ["_respawnTime", -1], ["_abandonDistance", 1000]];

// Always show on map
_veh setVariable ['QS_ST_drawEmptyVehicle',true, true];

if (_hasKeys) then {

    _veh setVariable [QVAR(hasKeys), true, true];

    // If it's killed/deleted we need to remove markers
    _veh addEventHandler ["killed", {
        params ["_veh", "_killer"];
        _owner = _veh getVariable QVAR(owner);
        [_owner, _veh, "remove"] call FNC(updateOwnership);
    }];

    _veh addEventHandler ["Deleted", {
        params ["_veh"];
        _owner = _veh getVariable QVAR(owner);
        [_owner, _veh, "remove"] call FNC(updateOwnership);
    }];
};

if !(_respawnTime isEqualTo -1) then {

    // Setup the loadout
    _loadout =  [
        getBackpackCargo _veh,
        getWeaponCargo _veh,
        getMagazineCargo _veh,
        getItemCargo _veh
    ];

    _pylonLoadout = [];
    if (_veh isKindOf "UAV") then {
        _pylonLoadout = GetPylonMagazines _veh;
    };

    // And just push back to the respawn list
    GVAR(respawnList) pushBack [
        _veh,
        typeOf _veh,
        getPosATL _veh,
        getDir _veh,
        _loadout,
        _pylonLoadout,
        _respawnTime,
        _abandonDistance,
        _hasKeys
    ];
};

// And we always ensure it's added to zeus
[[_veh]] call YFNC(addEditableObjects);

true;