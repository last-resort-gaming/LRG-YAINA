/*
Function: YAINA_CMD_fnc_pilotmsg

Description:
	Prints out a message informing about TS requirements for pilots.

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
    "pilotmsg",
    "%1, Welcome to the Last Resort Gaming public server. As a pilot you are required to be on our Discord server: discord.lastresortgaming.net"
] call FNC(generalMessage);