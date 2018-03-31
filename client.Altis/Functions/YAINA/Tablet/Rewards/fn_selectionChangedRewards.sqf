/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

params ["_lb", "_idx", ["_internal", false]];

// UI updates...
disableSerialization;

// we save our last idx so we can refresh the view on EH updates
GVAR(lastRewardSelection) = [_lb, _idx];

private _class = _lb lbData _idx;

private _ctrlGroup   = ctrlParentControlsGroup _lb;
private _orderButton = (_ctrlGroup controlsGroupCtrl 1600);
private _costText    = (_ctrlGroup controlsGroupCtrl 1202);


// Get price + build time from rewards publicVariable
GVAR(rewards) apply { _x select { _x select 0 isEqualTo _class; }; } select { !(_x isEqualTo []) } select 0 select 0
    params ["_class2", "_price", "_buildTime"];

// Set Image
(_ctrlGroup controlsGroupCtrl 1101) ctrlSetText (getText (configFile >> "CfgVehicles" >> _class >> "editorPreview"));

// Set Available Creds / Build Time
(_ctrlGroup controlsGroupCtrl 1201) ctrlSetText ([YVAR(rewardPoints),0,0,true] call CBAP_fnc_formatNumber);
(_ctrlGroup controlsGroupCtrl 1203) ctrlSetText (_buildTime call FNC(formatDuration));

// Cost Color
_costText ctrlSetText ([_price,0,0,true] call CBAP_fnc_formatNumber);
_costText ctrlSetTextColor ([[1,1,1,1], [1,0,0,1]] select (_price > YVAR(rewardPoints)));

// Spawn point Occupied ?
_sp = _class call FNC(getSpawnPoint);

if (triggerActivated _sp) then {
    (_ctrlGroup controlsGroupCtrl 1104) ctrlShow true;
    (_ctrlGroup controlsGroupCtrl 1204) ctrlShow true;
} else {
    (_ctrlGroup controlsGroupCtrl 1104) ctrlShow false;
    (_ctrlGroup controlsGroupCtrl 1204) ctrlShow false;
};

_orderButton ctrlEnable !(_price > YVAR(rewardPoints) || GVAR(orderRewardInProgress) || triggerActivated _sp);

// If the order is in progress locally, we can kill it, else, remain greyed out

// Any time we change selection, we cancel existing builds, if it's local
if !(_internal) then {
    call FNC(clickCancelReward);
};
