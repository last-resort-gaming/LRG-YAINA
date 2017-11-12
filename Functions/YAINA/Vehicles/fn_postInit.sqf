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


        if !(_veh getVariable [QVAR(hasEjectAction), false]) then {
            _veh addAction ["Eject Passenger",  {
                GVAR(EJECT_MENU) = [["Passenger to Eject", true]];
                {
                    if !(_x isEqualTo player) then {
                        // If it's the owner, just systemChat saying you can't eject the owner!
                        _owner = missionNamespace getVariable ((_this select 0) getVariable QVAR(owner));
                        if (isNil "_owner") then { _owner = objNull; };

                        if (_x isEqualTo _owner) then {
                            GVAR(EJECT_MENU) pushBack [
                                name _x, [0], "", -5, [["expression", "systemChat ""you can't eject the owner of this vehicle"" "]], "1", "1"
                            ];
                        } else {
                            GVAR(EJECT_MENU) pushBack [
                                name _x, [0], "", -5, [["expression", format ["['%1'] remoteExecCall ['%2', missionNamespace getVariable '%3']", name player, QFNC(ejectPax), _x call BIS_fnc_objectVar]]], "1", "1"
                            ];
                        };
                    };
                } forEach (crew vehicle player);

                showCommandingMenu format["#USER:%1", QVAR(EJECT_MENU)];

            }, "", 0, false, true, "", 'driver _target isEqualTo _this && count crew _target > 1'];

            _veh setVariable [QVAR(hasEjectAction), true];
        };

        // Because addAction is local, we just have an event handler on the
        // vehicle that'll add the actions when a player gets in - this caters
        // for respawned vehicles etc.

        if(_veh getVariable[QVAR(hasKeys), false]) then {

            if !(_veh getVariable [QVAR(hasKeyActions), false]) then {
                _veh addAction ["Take Keys",  FNC(takeKey), "", -98, false, true, "", format['driver _target isEqualTo _this && isNil { _target getVariable "%1"; }', QVAR(owner)]];
                _veh addAction ["Leave Keys", FNC(dropKey), "", -98, false, true, "", format['vehicle _this isEqualTo _target && (missionNamespace getVariable (_target getVariable "%1")) isEqualTo _this;', QVAR(owner)]];
                _veh setVariable [QVAR(hasKeyActions), true];
            };

            if (_pos isEqualTo "driver") then {
                _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
                if !(isNil "_owner") then {
                    if !([_owner isEqualTo (driver _veh), (group _owner) isEqualTo (group driver _veh)] select SQUAD_BASED) then {
                        format ["%1 has the keys.", name _owner] call YFNC(hintC);
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
            _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
            if (!(isNil "_owner")) then {
                if !([_owner isEqualTo (driver _veh), group _owner isEqualTo (group driver _veh)] select SQUAD_BASED) then {
                    ["You don't have the keys."] remoteExec [Q(YFNC(hintC)), driver _veh];
                    moveOut driver _veh;
                };
            };
        };
    }];

};