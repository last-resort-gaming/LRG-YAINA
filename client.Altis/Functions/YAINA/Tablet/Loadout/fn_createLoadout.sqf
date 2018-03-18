/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

// Get our type from the IDC
_type   = "B_CargoNet_01_ammo_F";
_tablet = findDisplay IDD_TABLET;

if !(_tablet isEqualTo displayNull) then {
    _typeBox = _tablet displayCtrl IDC_PAGE_AMMOBOX controlsGroupCtrl 1503;
    _type = _typeBox lbData (lbCurSel _typeBox);
};

// Simple task that takes our GVAR(loadout) and throws it over to our spawner
[GVAR(loadout), _type] call FNC(createSupplyDrop);

// And close the tab, back to requests
[IDC_PAGE_REQUESTS] call FNC(displayPage);