/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

[
    _this,
    "vehmsg",
    "%1, Do not board vehicles without HQ authorization",
    "All vehicles are locked by default. You are not allowed to take them without explicit permission by HQ!"
] call FNC(generalMessage);