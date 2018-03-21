/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_type"];

if (typeName _type isEqualTo "OBJECT") then {
    _type = typeOf _type;
};

isClass (configFile >> "CfgVehicles" >> _type) && { getNumber (configFile >> "CfgVehicles" >> _type >> "isUAV") isEqualTo 1 };