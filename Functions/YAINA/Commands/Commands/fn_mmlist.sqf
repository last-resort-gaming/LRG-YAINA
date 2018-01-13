/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

private _runningMissions = [];
{
    format ["%1 - %2", _x select 1, _x select 4] remoteExec ["systemChat", _owner];
    true;
} count (YAINA_MM_hcDCH select { !(_x select 2 isEqualTo "CLEANUP") });

""