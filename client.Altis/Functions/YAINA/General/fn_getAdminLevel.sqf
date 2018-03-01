/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_player"];

private _defaultAdminLevel = 5;

if !(isServer) exitWith {
    _player getVariable ["YAINA_adminLevel", _defaultAdminLevel];
};

if (isNil QYVAR(ownerIDs)) exitWith { _defaultAdminLevel };

private _owner = owner _player;

private _lvl = _defaultAdminLevel;

private _idx = (YVAR(ownerIDs) select 0) find _owner;
if !(_idx isEqualTo -1) then {
    _lvl = ((YVAR(ownerIDs) select 1) select _idx) select 3;
};

_lvl