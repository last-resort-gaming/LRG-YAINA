/*
	author: Martin
	description: none
	returns: nothing
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
                    deleteVehicle _v;
                };
                YVAR(deleteVehiclesIn) deleteAt _i;
            };
        };
    }, 5, []] call CBAP_fnc_addPerFrameHandler;
};
