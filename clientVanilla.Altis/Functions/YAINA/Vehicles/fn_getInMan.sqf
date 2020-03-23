/*
Function: YAINA_VEH_fnc_getInMan

Description:
	The event handler code run when the getInMan event is triggered.
    Checks player's access to a vehicle and ejects them from the 
    driver seat, if necessary.

Parameters:
	_unit - The player that got into a vehicle
    _pos - The position in the vehicle (the seat) where the player has entered
    _veh - The vehicle which the player entered
    _turret - The turret the player is controlling in the vehicle

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_unit", "_pos", "_veh", "_turret"];


// First we eject if need be
private _eject  = false;
private _ejectMessage = "You're not qualified to use this vehicle";

private _vehDrivers = _veh getVariable QVAR(Drivers);
if (_pos isEqualTo "driver" && { !(_veh isKindOf "ParachuteBase") } ) then {
    if(!isNil "_vehDrivers") then {
        if !(_vehDrivers call YFNC(testTraits)) then {
            _eject = true;
            private _message = _veh getVariable QVAR(DriversMessage);
            if !(isNil "_message") then {
                _ejectMessage = _message;
            };
        };
    } else {
        // Handle Default Air Vehicles
        if (_veh isKindOf "Air") then {
            // And lastly, default check, no pilot, no go.
            if !([["PILOT"], _unit] call YFNC(testTraits)) then {
                _eject = true;
                _ejectMessage = "You're not a pilot, you're not allowed to do that.";
            };
        };
    };
};

if (_eject) exitWith {
    moveOut _unit;
    [_ejectMessage] call YFNC(hintC);
};

if (_pos isEqualTo "driver") then {

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
                            name _x, [0], "", -5, [["expression", format ["moveOut (missionNamespace getVariable '%1')", _x call BIS_fnc_objectVar]]], "1", "1"
                        ];
                    };
                };
            } forEach (crew vehicle player);

            showCommandingMenu format["#USER:%1", QVAR(EJECT_MENU)];

        }, "", 0, false, true, "", 'driver _target isEqualTo _this && count crew _target > 1'];

        _veh setVariable [QVAR(hasEjectAction), true];
    };

    // for now, weonly enable turret control on air assets, but not UAVs as they have no driver
    if ((typeOf _veh) isKindOf "Air" && { !(_veh call YFNC(isUAV)) }) then {
        if !(_veh getVariable [QVAR(hasTurretControlAction), false]) then {
            // Get a list of non-empty turrets, non laser-designating for this vehicle
            if (count (("true" configClasses (configFile >> "CfgVehicles" >> typeOf _veh >> "Turrets") ) apply { getArray (_x >> "weapons") select { !(_x isEqualTo "Laserdesignator_mounted") } } select { !(_x isEqualTo []) }) > 0) then {
                _veh addAction ["Turret Control", {
                    params ["_target", "_caller", "_id", "_args"];
                    GVAR(TURRET_MENU) = [["Turret Control", true]];
                    {
                        _x params ["_title", "_weapons"];

                        if !(_weapons isEqualTo []) then {

                            _var = format["YAINA_turret_%1_act", _forEachIndex];
                            _en  = _target getVariable [_var, true];
                            _cmd = [
                                format ["{ [(missionNamespace getVariable '%1'), [_x, [%2]]] remoteExec ['addWeaponTurret',    (missionNamespace getVariable '%1') turretOwner [%2]]; nil } count %3; (missionNamespace getVariable '%1') setVariable [""%4"", true, true];",  _target call BIS_fnc_objectVar, _forEachIndex, _weapons, _var],
                                format ["{ [(missionNamespace getVariable '%1'), [_x, [%2]]] remoteExec ['removeWeaponTurret', (missionNamespace getVariable '%1') turretOwner [%2]]; nil } count %3; (missionNamespace getVariable '%1') setVariable [""%4"", false, true];", _target call BIS_fnc_objectVar, _forEachIndex, _weapons, _var]
                            ] select _en;

                            GVAR(TURRET_MENU) pushBack [
                                format["%1 %2", ["Unlock", "Lock"] select _en, _title],
                                [0], "", -5, [["expression", _cmd]], "1", "1"
                            ];
                        };
                    } forEach (("true" configClasses (configFile >> "CfgVehicles" >> typeOf _target >> "Turrets") ) apply {
                        [
                            getText (_x >> "gunnerName"),
                            getArray (_x >> "weapons") select { !(_x isEqualTo "Laserdesignator_mounted") }
                        ]
                    });

                    showCommandingMenu format["#USER:%1", QVAR(TURRET_MENU)];
                }, "", 10, false, true, "", 'driver _target isEqualTo _this'];
            };
            _veh setVariable [QVAR(hasTurretControlAction), true];
        };
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


        _owner = missionNamespace getVariable (_veh getVariable QVAR(owner));
        if !(isNil "_owner") then {
            if !([_owner isEqualTo (driver _veh), (group _owner) isEqualTo (group driver _veh)] select SQUAD_BASED) then {
                format ["%1 has the keys.", name _owner] call YFNC(hintC);
                moveOut driver _veh;
                _eject = true;
            };
        } else {
            // remove the variable so we can take it
            _veh setVariable [QVAR(owner), nil, true];
        };

    };
};

// Now, if we got this far, do a check juts in case the owner handler occurs
// then trigger our GetIn associated with the vehicles itself by addGetInHandler
if !(_eject) then {
    {
        // Ensure unit still in veh
        if ((vehicle _unit) isEqualTo _veh) then {
            [_unit, _pos, _veh, _turret, _x select 1] call (_x select 0);
        };
    } forEach (_veh getVariable [QVAR(getIn), []]);
};

