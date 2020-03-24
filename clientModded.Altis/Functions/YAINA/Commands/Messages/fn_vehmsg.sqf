/*
Function: YAINA_CMD_fnc_vehmsg

Description:
	Prints out a message warning about using vehicles without 
    permission.

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
    "vehmsg",
    "%1, do not board vehicles without permission",
    "All vehicles are locked by default. You are not allowed to take them without explicit permission from HQ"
] call FNC(generalMessage);