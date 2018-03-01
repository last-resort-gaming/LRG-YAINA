/*
	author: Martin
	description: none
	returns: nothing


	Default Admin Level needs to be set here adn getAdminLevel
*/

#include "defines.h"

params ["_uid"];

private _adminLevel = 5;

if !(isServer) exitWith { _adminLevel };
if (isNil QYVAR(admins)) exitWith { _adminLevel };

private _idx = (YVAR(admins) select 0) find _uid;
private _adminLevel = 0;
if !(_idx isEqualTo -1) then {
    _adminLevel = (YVAR(admins) select 1) select _idx;
};

_adminLevel