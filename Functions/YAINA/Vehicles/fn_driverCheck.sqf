
// Called post-init initialize GetInMan actions for driver validity checks

#include "defines.h"

if(!hasInterface) exitWith {};

player addEventHandler["GetInMan", {
    params ["_unit", "_position", "_veh", "_turretIndex"];

    private _eject = false;
    private _ejectMessage = "You're not qualified to use this vehicle";

    // We only care about driver as CoPilot disabled
    if !(_position isEqualTo "driver") exitWith {};

    // Skip if it's a parachute
    if (_veh isKindOf "ParachuteBase") exitWith {};

    // Allow explicit unit traits if set on the vehicle, before default rules
    private _vehDrivers = _veh getVariable QVAR(Drivers);
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
            if !(_unit getUnitTrait "YAINA_PILOT") then {
                _eject = true;
                _ejectMessage = "You're not a pilot, you're not allowed to do that.";
            };
        };
    };

    if (_eject) then {
        moveOut _unit;
        [_ejectMessage] call YFNC(hintC);
    };

}];