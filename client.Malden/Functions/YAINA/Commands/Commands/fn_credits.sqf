/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

_msg = format ["Credit Balance: %1", [YVAR(rewardPoints), 1, 0, true] call CBAP_fnc_formatNumber];
_msg remoteExecCall ["systemChat", _owner];
_msg