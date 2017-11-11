/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

if (hasInterface) then {

    if (player getUnitTrait "YAINA_HQ") then {
        player addAction [
            "Open Command Tablet",
            { call FNC(openTablet); }
        ];
    };
};