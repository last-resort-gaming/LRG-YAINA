/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_class"];

call {
    if (getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") isEqualTo 1) exitWIth { SP_UAV };
    if (_class isKindOf "Plane") exitWith {
        // Y-32 Xi'an + Blackfish to go to HELI spawn
        if((_class select [1, 9]) isEqualTo "_T_VTOL_0") exitWith { SP_HELI };
        SP_JET
    };
    if (_class isKindOf "Helicopter") exitWith { SP_HELI; };
    if (_class isKindOf "LandVehicle") exitWith { SP_VEH; };
};
