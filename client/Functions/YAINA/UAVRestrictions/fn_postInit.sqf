/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

player addEventHandler["Respawn", {
    call FNC(respawn);
}];

["UAVSpawn", {
    params ["_uav"];

    private _mertDrone = (typeOf _uav) isEqualTo "B_UAV_06_medical_F";

    if (["MERT_UAV"] call YAINA_fnc_testTraits) then {
        if !(_mertDrone) then {
            player disableUAVConnectability [_uav, true];
        };
    } else {
        if (_mertDrone) then {
            player disableUAVConnectability [_uav, true];
        };
    };
}] call CBAP_fnc_addEventHandler;

call FNC(respawn);