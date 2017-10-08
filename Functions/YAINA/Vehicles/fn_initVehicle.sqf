/*
	author: MartinCo
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_veh", ["_hasKeys", true],  ["_respawnTime", -1], ["_abandonDistance", 1000]];

if (_hasKeys) then {
    _veh addAction ["Take Keys",  FNC(takeKey), "", -98, false, true, "", format['driver _target isEqualTo _this && isNil { _target getVariable "%1"; }', QVAR(owner)]];
    _veh addAction ["Leave Keys", FNC(dropKey), "", -98, false, true, "", format['vehicle _this isEqualTo _target && (missionNamespace getVariable (_target getVariable "%1")) isEqualTo _this; }', QVAR(owner)]];

    // just run drop key on the owner's machine to clean up their own map markers
    // and local vehicle list - this'll update the server too, so should be all
    // consistant.
    _veh addEventHandler ["killed", {
        params ["_veh", "_killer"];
        _owner = _veh getVariable QVAR(owner);
        if !(isNil "_owner") then {
            [_veh, missionNamespace getVariable _owner] remoteExec [QFNC(dropKey), _owner];
        };
    }];

    // If we are deleted (zeus, or perhaps our friendly abandonment
    _veh addEventHandler ["Deleted", {
        params ["_veh"];
        _owner = _veh getVariable QVAR(owner);
        if !(isNil "_owner") then {
            [_veh, missionNamespace getVariable _owner] remoteExec [QFNC(dropKey), _owner];
        };
    }];

    // Whilst adding it to Engine is nicer, you could get greifing with players refusing to get out
    // So lets just add it to getIn / seat changed and force eject them from the vehicle.

    _veh addEventHandler ["SeatSwitched", {
        params ["_veh", "_unit1", "_unit2"];

        _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
        if (!(isNil "_owner")) then {
            if !([_owner isEqualTo (driver _veh), group _owner isEqualTo (group driver _veh)] select SQUAD_BASED) then {
                ["You don't have the keys."] remoteExec [QFNC(hintC), driver _veh];
                moveOut driver _veh;
            };
        };
    }];

    _veh addEventHandler ["GetIn", {
        params ["_veh", "_pos", "_unit", "_turret"];
        if (_pos isEqualTo "driver") then {
            _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
            if (!(isNil "_owner")) then {
                if !([_owner isEqualTo (driver _veh), (group _owner) isEqualTo (group driver _veh)] select SQUAD_BASED) then {
                    ["You don't have the keys."] remoteExec [QFNC(hintC), driver _veh];
                    moveOut driver _veh;
                };
            };
        };
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

    // And just push back to the respawn list
    GVAR(respawnList) pushBack [
        _veh,
        typeOf _veh,
        getPosATL _veh,
        getDir _veh,
        _loadout,
        _respawnTime,
        _abandonDistance,
        _hasKeys
    ];
};


true;