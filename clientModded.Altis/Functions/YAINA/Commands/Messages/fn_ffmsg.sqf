/*
Function: YAINA_CMD_fnc_ffmsg

Description:
	Prints out a message warning about friendly fire.

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
    "ffmsg",
    "%1, friendly fire is strictly prohibited on this server. This is your only warning. Abide by the rules or you will be removed",
    "Friendly fire is strictly prohibited, those found in violation will be removed immediately"
] call FNC(generalMessage);