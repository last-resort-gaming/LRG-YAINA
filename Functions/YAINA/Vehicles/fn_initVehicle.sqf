/*
	author: MartinCo
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_veh", ["_hasKeys", true],  ["_respawnTime", -1], ["_abandonDistance", 1000], ["_persistVars", []]];

// Always show on map
_veh setVariable ['QS_ST_drawEmptyVehicle',true, true];

if (_hasKeys) then {

    _veh setVariable [QVAR(hasKeys), true, true];

    // If it's killed/deleted we need to remove markers
    _veh addEventHandler ["killed", {
        params ["_veh", "_killer"];
        _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
        if (!isNil "_owner") then { [_owner, _veh, "remove"] call FNC(updateOwnership); };
    }];

    _veh addEventHandler ["Deleted", {
        params ["_veh"];
        _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
        if (!isNil "_owner") then { [_owner, _veh, "remove"] call FNC(updateOwnership); };
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

    // Save any wing fold state
    _animationInfo = [];
    if(_veh isKindOf "Plane") then {
        _wingFoldAnimationsList = [(configFile >> "CfgVehicles" >> typeOf _veh  >> "AircraftAutomatedSystems"), "wingFoldAnimations", []] call BIS_fnc_returnConfigEntry;
        { _animationInfo pushBack [_x, _veh animationPhase _x]; } forEach _wingFoldAnimationsList;
    };

    // Save any pylon weapon loadouts
    _pylonLoadout = [];
    if (_veh isKindOf "UAV") then {
        _pylonLoadout = GetPylonMagazines _veh;
    };

    // Save persist vars
    _persistVarsSave = _persistVars apply { [_x, _veh getVariable _x] };

    // And just push back to the respawn list
    GVAR(respawnList) pushBack [
        _veh,
        typeOf _veh,
        getPosATL _veh,
        getDir _veh,
        getObjectTextures _veh,
        isCopilotEnabled _veh,
        _loadout,
        _animationInfo,
        _pylonLoadout,
        _respawnTime,
        _abandonDistance,
        _hasKeys,
        _persistVarsSave
    ];
};

// And we always ensure it's added to zeus
[[_veh]] call YFNC(addEditableObjects);

true;