/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

BASE_PROTECTION_AREAS + (GVAR(paradropMarkers) apply { [getMarkerPos _x, getMarkerSize _x apply { _x * 2 }] });