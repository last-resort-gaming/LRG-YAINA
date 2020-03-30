/*
Function: YAINA_CMD_fnc_helimsg

Description:
	Prints out a message warning about boarding helicopters 
    without permission.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

[
    _this,
    "helimsg",
    "%1, do not board helicopters without permission, You may be ejected from the aircraft mid-flight. Wait for your section commander to call for transport",
    "Do not board helicopters without permission! You may be ejected from the aircraft mid-flight. Wait for your section commander to call for transport"
] call FNC(generalMessage);