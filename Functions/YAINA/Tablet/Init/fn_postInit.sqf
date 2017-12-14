/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

if (hasInterface) then {

    if (["HQ"] call YFNC(testTraits)) then {
        player addAction [
            "Open Command Tablet",
            { call FNC(openTablet); }
        ];
    };
};