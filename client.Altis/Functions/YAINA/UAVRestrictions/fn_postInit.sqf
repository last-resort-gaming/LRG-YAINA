/*
Function: YAINA_UAV_fnc_postInit

Description:
	Handles initialization of the UAV submodule during the postInit
    phase. Mainly concerned with adding the necessary event handlers
    and setting some variables.

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

player addEventHandler["Respawn", {
    call FNC(respawn);
}];

player addEventHandler ["WeaponAssembled", {
    params ["_unit", "_weapon"];

    _disassemble = false;

    if (typeOf _weapon isEqualTo "B_UAV_01_F") then {
        if (yaina_uav_limit_darters > 0) then {
            if ({ typeOf _x isEqualTo "B_UAV_01_F" } count allUnitsUAV  > yaina_uav_limit_darters) then {
                _disassemble = format["Only %1 Darter%2 may be deployed at any given time", yaina_uav_limit_darters, ["s", ""] select (yaina_uav_limit_darters isEqualTo 1)];
            };
        };
    };

    if (typeOf _weapon isEqualTo "B_UAV_06_medical_F") then {

        if (yaina_uav_limit_pelicans > 0) then {
            if ({ typeOf _x isEqualTo "B_UAV_06_medical_F" } count allUnitsUAV > yaina_uav_limit_pelicans) then {
                _disassemble = format["Only %1 Pelican%2 may be deployed at any given time", yaina_uav_limit_pelicans, ["s", ""] select (yaina_uav_limit_pelicans isEqualTo 1)];
            };
        };

        // If not disassembled, then we make it a emdical station
        if (_disassemble isEqualTo false) then {
            [_weapon, 20] call AIS_Core_fnc_addMedicStation;
        };
    };

    if (_disassemble isEqualTo false) then {

        // Anything assembled should probably belong in zeus
        [[_weapon], ture] call YFNC(addEditableObjects);

        // Global event in case of being a UAV to ensure the relevent
        // UAV Terminals can connect to it
        if (_weapon call YFNC(isUAV)) then {
            ["UAVSpawn", [_weapon]] call CBAP_fnc_globalEvent;
        };
    } else {
          _unit action ["Disassemble", _weapon];
          _disassemble call YFNC(hintC)
    };
}];

player addEventHandler ["Take", {
    params ["_unit", "_container", "_item"];

    private _cf = configFile >> "CfgWeapons" >> _item >> "itemInfo" >> "type";

    if (isClass _cf && { getNumber _cf isEqualTo 621 }) then {
        call FNC(rescan);
    };
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