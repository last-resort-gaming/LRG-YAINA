/*
Function: YAINA_TABLET_fnc_clickRewardsButton

Description:
	Initializes the rewards page, populating the page and setting 
    up the buttons and handlers.

Parameters:
	_enabled - Is the rewards spawner enabled?

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

disableSerialization;

params ["_enabled"];

[format ["ClickRewards with: %1", _this]] call YFNC(log);

// Get Enabled Control from IDC given to command
private _tablet = (findDisplay IDD_TABLET); if(_tablet isEqualTo displayNull) exitWith {};
private _ctrl   = _tablet displayCtrl IDC_PAGE_REWARDS;

// set the color state of the buttons other than enabled
for "_i" from 30 to 33 do {

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

// Populate LB
private _lb = _ctrl controlsGroupCtrl 1500;
lbClear _lb;

{
    _idx = _lb lbAdd (getText(configFile >> "CfgVehicles" >> (_x select 0) >> "displayName"));
    _lb lbSetData [_idx, _x select 0];
} forEach (GVAR(rewards) select (_enabled -30));

// Sort it
//lbSort _lb;

// We also just select first item currently so we dont start half way down
// it also triggers the generation of the buy pane...
_lb lbSetCurSel 0;