/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_player"];

if ([["HQ"], _player] call YFNC(testTraits) || { [_player] call YFNC(getAdminLevel) <= 2 }) then {

    [[], {
        player addAction [
            "Open Command Tablet",
            { call FNC(openTablet); },
            [],
            1.5,
            false
        ];
    }] remoteExec ["call", _player];
};
