/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_class"];

call {
    if (getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") isEqualTo 1) exitWIth { SP_UAV };
    if (_class isKindOf "Plane") exitWith { SP_JET };
    if (_class isKindOf "Helicopter") exitWith { SP_HELI; };
    if (_class isKindOf "LandVehicle") exitWith { SP_VEH; };
};
