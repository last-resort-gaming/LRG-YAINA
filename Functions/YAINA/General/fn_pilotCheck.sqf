
// Called post-init initialize GetInMan actions for pilot check

// TLDR: only pilots can get in air vehicles, except MERT who can
// fly the MERT chopper

#include "defines.h"

if(!hasInterface) exitWith {};

player addEventHandler["GetInMan", {
    params ["_unit", "_position", "_veh", "_turretIndex"];

    // We only care about driver as CoPilot disabled
    if !(_position isEqualTo "driver") exitWith {};

    if !(_veh isKindOf "Air" && {!(_veh isKindOf "ParachuteBase")}) exitWith {};

    // If we are MERT, and this is a MERT vehicle, permit
    if (_unit getUnitTrait "YAINA_MERT" && _veh getVariable ["YAINA_MERT", false]) exitWith {};

    // And lastly, default check, no pilot, no go.
    if !(typeOf _unit in ["B_Fighter_Pilot_F", "B_Helipilot_F", "B_Pilot_F", "B_T_Pilot_F", "B_T_Helipilot_F"]) then {
        moveOut _unit;
        ["You're not a pilot, you're not allowed to do that."] call YFNC(hintC);
    };
}];