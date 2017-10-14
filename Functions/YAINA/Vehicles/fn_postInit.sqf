/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

if(isServer) then {

    [] call FNC(respawnPFH);

    // And unlock all the players vehicles on DC
    addMissionEventHandler ["HandleDisconnect", { [_this select 0, nil, "remove"] call FNC(updateOwnership) } ];

};

if(hasInterface) then {

    // And we need a respawn handler to add back in the player actioon for unlcoking all vehicles
    player addEventHandler ["Respawn", {
        call FNC(updatePlayerActions);
    }];

    player addEventHandler ["GetInMan", {
        params ["_unit", "_pos", "_veh", "_turret"];

        // Because addAction is local, we just have an event handler on the
        // vehicle that'll add the actions when a player gets in - this caters
        // for respawned vehicles etc.

        if(_veh getVariable[QVAR(hasKeys), false]) then {

            if ((count actionIDs _veh) isEqualTo 0) then {
                _veh addAction ["Take Keys",  FNC(takeKey), "", -98, false, true, "", format['driver _target isEqualTo _this && isNil { _target getVariable "%1"; }', QVAR(owner)]];
                _veh addAction ["Leave Keys", FNC(dropKey), "", -98, false, true, "", format['vehicle _this isEqualTo _target && (_target getVariable "%1") isEqualTo _this;', QVAR(owner)]];
            };

            if (_pos isEqualTo "driver") then {
                _owner = _veh getVariable QVAR(owner);
                if (!(isNil "_owner")) then {
                    if !([_owner isEqualTo (driver _veh), (group _owner) isEqualTo (group driver _veh)] select SQUAD_BASED) then {
                        ["You don't have the keys."] remoteExec [Q(YFNC(hintC)), driver _veh];
                        moveOut driver _veh;
                    };
                } else {
                    // remove the variable so we can take it
                    _veh setVariable [QVAR(owner), nil, true];
                };
            };
        };
    }];

    // Whilst adding it to Engine is nicer, you could get greifing with players refusing to get out
    // So lets just add it to getIn / seat changed and force eject them from the vehicle.

    player addEventHandler ["SeatSwitchedMan", {
        params ["_unit1", "_unit2", "_veh"];

        if(_veh getVariable[QVAR(hasKeys), false]) then {
            _owner = _veh getVariable QVAR(owner);
            if (!(isNil "_owner")) then {
                if !([_owner isEqualTo (driver _veh), group _owner isEqualTo (group driver _veh)] select SQUAD_BASED) then {
                    ["You don't have the keys."] remoteExec [Q(YFNC(hintC)), driver _veh];
                    moveOut driver _veh;
                };
            };
        };
    }];

};