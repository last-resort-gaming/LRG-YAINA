/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

private _mert = ["MERT_UAV"] call YAINA_fnc_testTraits;

{
    if !((AIR_DEFENCES find _x) isEqualTo -1) then {
        player disableUAVConnectability [_x, true];
    } else {
        if (typeOf _x isEqualTo "B_UAV_06_medical_F") then {
            if !(_mert) then {
                player disableUAVConnectability [_x, true];
            };
        } else {
            if (_mert) then {
                player disableUAVConnectability [_x, true];
            }
        };
    };
    true;
} count allUnitsUAV;