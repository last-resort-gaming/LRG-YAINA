/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

if (hasInterface) then {
    GVAR(lastParadrop)    = 0;             // List time client paradroped
    GVAR(paradropTimeout) = 300;           // Time between consecutive drops
};
