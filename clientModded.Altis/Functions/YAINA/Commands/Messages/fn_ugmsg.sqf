/*
Function: YAINA_CMD_fnc_ugmsg

Description:
	Prints out a message warning about deploying ungrouped.

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
    "ugmsg",
    "%1, please join a section and request your squad leader to arrange you transport - alternatively, start a group and request transport when you have at least 4 members.",
    "Could all ungrouped players back at base please join an existing section and request your new squad lead for transport, or start a new section and request transport once you have at least 4 members"
] call FNC(generalMessage);