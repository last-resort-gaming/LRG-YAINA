/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

// Simple task that takes our GVAR(loadout) and throws it over to our spawner
[GVAR(loadout), nil, true, true] call FNC(createSupplyDrop);

// And close the tab, back to requests
[IDC_PAGE_REQUESTS] call FNC(displayPage);