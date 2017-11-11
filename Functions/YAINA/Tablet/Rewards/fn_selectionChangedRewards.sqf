/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_lb", "_idx"];

// UI updates...
disableSerialization;

private _class = _lb lbData _idx;

private _ctrlGroup   = ctrlParentControlsGroup _lb;
private _orderButton = (_ctrlGroup controlsGroupCtrl 1601);
private _costText    = (_ctrlGroup controlsGroupCtrl 1202);
// Get price + build time from rewards publicVariable
GVAR(rewards) apply { _x select { _x select 0 isEqualTo _class; }; } select { !(_x isEqualTo []) } select 0 select 0
    params ["_class2", "_price", "_buildTime"];


// Set Image
(_ctrlGroup controlsGroupCtrl 1101) ctrlSetText (getText (configFile >> "CfgVehicles" >> _class >> "editorPreview"));

// Set Available Creds / Build Time
(_ctrlGroup controlsGroupCtrl 1201) ctrlSetText ([YVAR(rewardPoints),0,0,true] call CBA_fnc_formatNumber);
(_ctrlGroup controlsGroupCtrl 1203) ctrlSetText (_buildTime call FNC(formatDuration));


_costText ctrlSetText ([_price,0,0,true] call CBA_fnc_formatNumber);
// Too much ?
if (_price > YVAR(rewardPoints)) then {
    // Set to red, and disable order button
    _costText ctrlSetTextColor [1,0,0,1];
    _orderButton ctrlEnable false;
} else {
    _costText ctrlSetTextColor [1,1,1,1];
    _orderButton ctrlEnable true;
};