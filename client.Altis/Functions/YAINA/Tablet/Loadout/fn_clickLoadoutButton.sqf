#include "..\defines.h"

disableSerialization;

params ["_elem", ["_select", true]];

private _ctrl    = ctrlParentControlsGroup _elem;
private _enabled = ctrlIDC _elem;

// set the color state of the buttons other than enabled
for "_i" from 30 to 40 do {

    _bg = [0,0,0,1];
    _fg = [0.8, 0.8, 0.8, 1];

    if (_i isEqualTo _enabled) then {
        _bg = [0.403922, 0.294118, 0.125490, 1];
        _fg = [1,1,1,1];
    };

    _button   = _ctrl controlsGroupCtrl _i;
    _buttonbg = _ctrl controlsGroupCtrl (_i + 20);

    _button   ctrlSetTextColor _fg;
    _buttonbg ctrlSetBackgroundColor _bg;
};

// Now, if active isn't 30 (player), deselect user selection
// Now, if we are 30, then we need to re-select loadout_last_idx
if (!_select) exitWith {};

if (_enabled isEqualTo 30) exitWith {
    (_ctrl controlsGroupCtrl 1500) lbSetCurSel GVAR(loadout_last_idx);
};

(_ctrl controlsGroupCtrl 1500) lbSetCurSel -1;

/*
Now we process buttons 31-40; https://community.bistudio.com/wiki/CfgWeapons_Config_Reference
so, always: scope == 2 => can use in-game, with a picture in gear present
type:
 1 - primary
 2 - sidearm
 4 - secondary
   - also includes mine detector, so also make sure it shooty shoots
 4096 - Binoculars

ItemInfo Types:
#define HEADGEAR	605
#define UNIFORM		801
#define VEST		701
#define OPTICS		201
KITS 619
*/

/*
30 - player
31 - primary
32 - secondary
33 - sidearm
34 - mags
35 - Scopes
36 - uniform
37 - vests
38 - backopacks
39 - headgear
40 - items (binos, medpacks, medkits, UAV terms)
*/



_items = call {
    if (_enabled isEqualTo 31) exitWith { "getnumber (_x >> 'type') isEqualTo 1 AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> 'CfgWeapons'); };
    if (_enabled isEqualTo 32) exitWith {
        "getnumber (_x >> 'type') isEqualTo 4 AND getnumber (_x >> 'scope') isEqualTo 2 AND count(getArray(_x >> 'magazines')) > 0"
            configClasses (configFile >> 'CfgWeapons'); };
    if (_enabled isEqualTo 33) exitWith { "getnumber (_x >> 'type') isEqualTo 2 AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> 'CfgWeapons'); };
    if (_enabled isEqualTo 34) exitWith { "!(getnumber (_x >> 'type') isEqualTo 0) AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> 'CfgMagazines'); };
    if (_enabled isEqualTo 35) exitWith { "getnumber (_x >> 'ItemInfo' >> 'Type') isEqualTo 201 AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> 'CfgWeapons'); };
    if (_enabled isEqualTo 36) exitWith { "getnumber (_x >> 'ItemInfo' >> 'Type') isEqualTo 801 AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> 'CfgWeapons'); };
    if (_enabled isEqualTo 37) exitWith { "getnumber (_x >> 'ItemInfo' >> 'Type') isEqualTo 701 AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> 'CfgWeapons'); };
    if (_enabled isEqualTo 38) exitWith { "getText (_x >> 'vehicleClass') isEqualTo 'Backpacks' AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> 'CfgVehicles'); };
    if (_enabled isEqualTo 39) exitWith { "getnumber (_x >> 'ItemInfo' >> 'Type') isEqualTo 605 AND getnumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> 'CfgWeapons'); };
    if (_enabled isEqualTo 40) exitWith {
        // get all our Binos or FAKs/medikit/toolkit/UAV terms
        _a = "getnumber (_x >> 'scope') isEqualTo 2 AND ((getnumber (_x >> 'type') isEqualTo 4096) OR (!([401,619,620,621] find getnumber (_x >> 'ItemInfo' >> 'Type') isEqualTo -1)))"
                configClasses (configFile >> 'CfgWeapons');
        _a + [configFile >> "CfgWeapons" >> "MineDetector"];
    };
    []
};

// now clear the LB and reload it...
[_items] call FNC(populateLoadout);