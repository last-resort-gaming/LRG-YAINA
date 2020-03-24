/*
Function: YAINA_CMD_fnc_credits

Description:
	Inform players of the current credits balance.

Parameters:
	_owner - Not used
	_caller - Not used
	_argStr - Not used

Return Values:
	The compiled message, for internal handling

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

_msg = format ["Credit Balance: %1", [YVAR(rewardPoints), 1, 0, true] call CBAP_fnc_formatNumber];
_msg remoteExecCall ["systemChat", _owner];
_msg