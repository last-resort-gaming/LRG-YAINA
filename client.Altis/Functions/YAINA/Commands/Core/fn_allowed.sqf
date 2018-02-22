/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_caller", "_requiredLvl"];

// Lookup admin level
private _lvl = [_caller] call YFNC(getAdminLevel);
_lvl <= _requiredLvl