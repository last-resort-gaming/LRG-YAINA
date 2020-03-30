/*
Function: YAINA_CMD_fnc_uavmsg

Description:
	Prints out a message informing about TS requirements for UAV 
	operators.

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
    "uavmsg",
    "%1, welcome to the Last Resort Gaming public server. As UAV operator you are required to be on our Discord server: discord.lastresortgaming.net"
] call FNC(generalMessage);