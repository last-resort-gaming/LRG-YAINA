/*
Function: YAINA_CMD_fnc_bppause

Description:
	Pause or resume Base Protection.
    Admins will be notified of this.

Parameters:
	_owner - Not used
    _caller - The player that called this command
    _argStr - Not used

Return Values:
	Compiled message for internal handling

Examples:
    Nothing to see here

Author:
	Matth
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _msg = "";


if (yaina_allow_firing_at_base) then {
    yaina_allow_firing_at_base = false;
    _msg  = "Base Protection enabled.";
} else {
    yaina_allow_firing_at_base = true;
    _msg = "Base Protection disabled.";
};

// Let Admins know
[_caller, _msg, 3] call FNC(notifyAdmins);

_msg