/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

player addEventHandler ["WeaponAssembled", {
    params ["_unit", "_weapon"];
    if (typeOf _weapon isEqualTo "B_UAV_06_medical_F") then {
        [_weapon, 20] call AIS_Core_fnc_addMedicStation;
    };

    // Global event in case of being a UAV
    if (_weapon call YFNC(isUAV)) then {
        ["UAVSpawn", [_weapon]] call CBAP_fnc_globalEvent;
    };
}];

player addEventHandler ["Take", {
    params ["_unit", "_container", "_item"];

    private _cf = configFile >> "CfgWeapons" >> _item >> "itemInfo" >> "type";

    if (isClass _cf && { getNumber _cf isEqualTo 621 }) then {
        call FNC(rescan);
    };
}];

// Lock what we have now...
call FNC(rescan);