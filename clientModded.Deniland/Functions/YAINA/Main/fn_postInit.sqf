/*
Function: YAINA_fnc_postInit

Description:
	General postInit handler for YAINA. This initializes global variables for
    hidden terrain objects, scheduled vehicle deletions and issued warnings.
    Starts the scheduled vehicle removal, and adjusts some AIS settings.
    Also adds all existing units and vehicles to Zeus.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

if (isServer) then {
    YVAR(hiddenTerrainObjects) = [[], []];
    YVAR(deleteVehiclesIn) = [];
    YVAR(warnings) = [[], []];

    [{
        _t = diag_tickTime;
        _c = count YVAR(deleteVehiclesIn);
        for "_i" from (_c - 1) to 0 step -1 do {
            if (YVAR(deleteVehiclesIn) select _i select 1 <= _t) then {
                _v = YVAR(deleteVehiclesIn) select _i select 0;
                if !(isNull _v) then {
                    { _v deleteVehicleCrew _x ; nil } count (crew _v);
                    deleteVehicle _v;
                };
                YVAR(deleteVehiclesIn) deleteAt _i;
            };
        };

        // Set AIS Bleedout Multiplier based on MERT presence
        AIS_BLEEDOUT_MULTIPLIER = [1,2] select (({ if ([["MERT"], _x] call YFNC(testTraits)) exitWith { 1 }; nil } count allPlayers) isEqualTo 1);
        publicVariable "AIS_BLEEDOUT_MULTIPLIER";

    }, 5, []] call CBA_fnc_addPerFrameHandler;

    // By default, we always add all vehicles and units to zeus, there shouldn't be any by default, but for zeus
    // missions this is quite useful
    [allUnits + vehicles, true] call YFNC(addEditableObjects);
};
