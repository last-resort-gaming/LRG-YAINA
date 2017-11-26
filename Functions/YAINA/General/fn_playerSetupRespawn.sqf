/*
	author: Martin
	description: none
	returns: nothing
*/

// When we spawn a Medical UAV, add it to mobile medical stations
player addEventHandler ["WeaponAssembled", {
    params ["_unit", "_weapon"];
    if (typeOf _weapon isEqualTo "B_UAV_06_medical_F") then {
        [_weapon, 20] call AIS_Core_fnc_addMedicStation;
    };
}];