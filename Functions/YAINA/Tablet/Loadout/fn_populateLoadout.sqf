/*
	author: Martin
	description:
	    Takes an array of ConfigFile elements, to populate the AmmoBox Loadout
	    ListNBox to manage the quantities in the loadout
	returns: nothing
*/
#include "..\defines.h"

params ["_cfgItemList"];

_xlb = (findDisplay IDD_TABLET) displayCtrl IDC_PAGE_AMMOBOX controlsGroupCtrl 1501;
lbClear _xlb;

{
    _base = _x;
    _id = configName _base;
    _dn = getText (_base >> "displayName");

    // If we have linked items, add them, only relevent to weapons
    {
        _attachmentDN = getText(configFile >> "CfgWeapons" >> getText(_x >> "item") >> "displayName");
        if(!(isNil "_attachmentDN")) then {
            _dn = format ["%1 + %2", _dn, _attachmentDN];
        }
    } forEach ("true" configClasses (_base >> "LinkedItems"));

    _cidx = (GVAR(loadout) select 0) find _id;
    _cnt  = 0;
    if (!(_cidx isEqualTo -1)) then {
        _cnt = (GVAR(loadout) select 1) select _cidx;
    };

    // need to truncate to n chars
    _idx = _xlb lnbAddRow [_dn, str _cnt];
	_xlb lnbSetPicture [[_idx, 0], getText(_base >> "picture")];

	// We set the config parent data so we can choose the correct add type when we fill the loadout
	_xlb lnbSetData [[_idx, 1], _id];

} forEach (_cfgItemList);

// We also want to deselect what's currently selected so we dont start half way down
_xlb lnbSetCurSelRow -1;