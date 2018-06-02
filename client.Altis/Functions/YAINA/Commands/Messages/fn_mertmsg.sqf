/*
Function: YAINA_CMD_fnc_mertmsg

Description:
	Prints out a message informing about MERT presence.

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
    "mertmsg",
    nil,
    "MERT is now online - DO NOT RESPAWN. Section commanders can request MERT support via the HQ Channel"
] call FNC(generalMessage);