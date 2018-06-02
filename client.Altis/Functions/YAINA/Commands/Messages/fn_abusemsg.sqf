/*
Function: YAINA_CMD_fnc_abusemsg

Description:
	Prints out a message warning about abusive behaviour.

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
    "abusemsg",
    "%1, we do not allow harassment or abusive behaviour on our server. Continue and you will be removed without further warning",
    "We do not allow harassment or abusive behaviour. Continue and you will be removed without further warning"
] call FNC(generalMessage);