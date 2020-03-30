/*
Function: YAINA_CMD_fnc_hqmsg

Description:
	Prints out a message informing about TS requirements for HQ.

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
    "hqmsg",
    "%1, welcome to the Last Resort Gaming public server. As HQ you are required to be on our Discord server: discord.lastresortgaming.net"
] call FNC(generalMessage);