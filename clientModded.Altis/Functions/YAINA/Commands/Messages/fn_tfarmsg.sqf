/*
Function: YAINA_CMD_fnc_tfarmsg

Description:
	Prints out a message warning about TFAR Use

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Matth
*/

#include "..\defines.h"

[
    _this,
    "vehmsg",
    "%1, you must join our TeamSpeak and connect to our Task Force Radio Channel to play on this server!",
    "Task Force Radio is required to be on this server. Please join TeamSpeak and setup TFAR."
] call FNC(generalMessage);