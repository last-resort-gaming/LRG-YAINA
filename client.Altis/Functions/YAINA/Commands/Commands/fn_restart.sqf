/*
Function: YAINA_CMD_fnc_restart

Description:
	Restarts the mission.

Parameters:
	_owner - Not used
	_caller - The player that called this command
	_argStr - Not used

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

// Curious case, we must log here, due to the impending restart
[_caller, "restart", true, "restarting"] call FNC(log);
SERVER_COMMAND_PASSWORD serverCommand "#restart";