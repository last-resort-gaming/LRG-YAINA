/*
	author: Martin
	description: none
	returns: nothing
*/

params ["_testObj"];

private _type = typeOf _testObj;
isClass (configFile >> "CfgVehicles" >> _type) && { getNumber (configFile >> "CfgVehicles" >> _type >> "isUAV") isEqualTo 1 };