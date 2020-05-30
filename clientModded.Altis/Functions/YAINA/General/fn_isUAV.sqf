/*
Function: YAINA_fnc_isUAV

Description:
	Check if given object's class is that of an UAV.

Parameters:
	_type - The class name of the vehicle we're checking

Return Values:
	true if the class given is an UAV, false otherwise

Examples:
    Nothing to see here

Author:
	Martin
*/

params ["_type"];

if (typeName _type isEqualTo "OBJECT") then {
    _type = typeOf _type;
};

isClass (configFile >> "CfgVehicles" >> _type) && { getNumber (configFile >> "CfgVehicles" >> _type >> "isUAV") isEqualTo 1 };