/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

[
    _this,
    "vehmsg",
    "%1, do not board vehicles without permission",
    "All vehicles are locked by default. You are not allowed to take them without explicit permission from HQ"
] call FNC(generalMessage);