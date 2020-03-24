/*
Function: YAINA_UAV_fnc_rescan

Description:
	Rescan for UAVs to keep the list up-to-date, making sure that no
    unwanted UAVs are made available, eg. the base AA, or MERT drones.

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