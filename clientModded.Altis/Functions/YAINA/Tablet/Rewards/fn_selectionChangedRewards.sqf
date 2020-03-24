/*
Function: YAINA_TABLET_fnc_selectionChangedRewards

Description:
	Runs when the selection changed on the rewards page.
    Updates the price, spawn delay and similar information.

Parameters:
	_lb - The listbox containing all the entries
    _idx - The currently selected element
    _internal - If we are already building stuff, cancel that build if we change the selection

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

params ["_lb", "_idx", ["_internal", false]];

// UI updates...
disableSerialization;

// Refresh ?
private _refresh = GVAR(lastRewardSelection) isEqualTo [_lb, _idx];

// we save our last idx so we can refresh the view on EH updates
GVAR(lastRewardSelection) = [_lb, _idx];

private _class       = _lb lbData _idx;
private _display     = findDisplay IDD_TABLET;
private _ctrlGroup   = ctrlParentControlsGroup _lb;
private _orderButton = (_ctrlGroup controlsGroupCtrl 1600);
private _costText    = (_ctrlGroup controlsGroupCtrl 1202);


// Get price + build time from rewards publicVariable
GVAR(rewards) apply { _x select { _x select 0 isEqualTo _class; }; } select { !(_x isEqualTo []) } select 0 select 0
    params ["_class2", "_price", "_buildTime"];

// Set Image
(_ctrlGroup controlsGroupCtrl 1101) ctrlSetText (getText (configFile >> "CfgVehicles" >> _class >> "editorPreview"));

// Create Controls for the user elements
_garageAnimations = configProperties [configFile >> "CfgVehicles" >> _class >> "AnimationSources"] select {
    !(getText(_x >> "displayName") isEqualTo "") && { getnumber (_x >> "scope") > 1  || !isnumber (_x >> "scope") }
};

// If it's just a refresh, we keep our controls
if !(_refresh) then {

    // Delete any existing controls, and create new ones
    { ctrlDelete _x; nil; } count (GVAR(animationControls) select 0);
    { ctrlDelete _x; nil; } count GVAR(animationControlsText);
    GVAR(animationControls) = [[],[]];
    GVAR(animationControlsText) = [];

    private _lastBox = (_ctrlGroup controlsGroupCtrl 1101);
    {

        _ctrlGroupS  = ctrlPosition _ctrlGroup;
        _configName  = configName _x;
        _configNameL = toLower _configName;
        _checkbox    = _display ctrlCreate ["RscCheckbox", -1, _ctrlGroup];

        // Position it below the previous one, and update
        _lpos    = ctrlPosition _lastBox;
        _checked = (getNumber (_x >> "initPhase") isEqualTo 1);

        _p = [(_lpos select 0), (_lpos select 1) + (_lpos select 3) + 0.01, 0.025, 0.03];
        _checkbox ctrlSetPosition _p;
        _checkbox cbSetChecked _checked;
        _checkbox ctrlCommit 0;

        // Add some text
        _p set [0, (_p select 0) + 0.03];
        _text = _display ctrlCreate ["GarageAnimation", -1, _ctrlGroup];
        _text ctrlSetPosition [(_p select 0) + 0.005, _p select 1];
        _text ctrlSetText (getText (_x >> "displayName"));
        _text ctrlCommit 0;

        // Price Adjustment ?
        // If it's Camonet         => 50 credits
        // If it's showSLATHull    => 500 credits
        // If it's any other SLAT  => 250 credits
        _optCost = call {
            if !(_configNameL find "slathull" isEqualTo -1) exitWith { 500 };
            if !(_configNameL find "slat" isEqualTo -1)     exitWith { 250 };
            if !(_configNameL find "camonet" isEqualTo -1)  exitWith { 50 };
            0
        };

        if !(_optCost isEqualTo 0) then {
            _optCostCtrl = _display ctrlCreate ["GarageAnimationR", -1, _ctrlGroup];
            _optCostCtrl ctrlSetPosition [((_ctrlGroupS select 2) / 3), _p select 1];
            _optCostCtrl ctrlSetText (format ["+%1 credits", [_optCost,0,0,true] call CBAP_fnc_formatNumber]);
            _optCostCtrl ctrlCommit 0;


            // if we're checked add the optcost
            if (_checked) then {
                _price = _price + _optCost;
            };

            // When we check the box, we add the cost, by refreshing the selection
            _checkbox ctrlAddEventHandler ['CheckedChanged', {
                GVAR(lastRewardSelection) call FNC(selectionChangedRewards);
            }];

            // Add to cleanup
            GVAR(animationControlsText) pushBack _optCostCtrl;
        };

        // Now add some text with the animation name
        (GVAR(animationControls) select 0) pushBack _checkbox;
        (GVAR(animationControls) select 1) pushBack [_configName, _optCost];
        GVAR(animationControlsText) pushBack _text;

        _lastBox = _checkbox;

        nil
    } count _garageAnimations;
} else {
    // But we do re-calculate costs if applicable
    {
        if (cbChecked _x) then {
            _price = _price + (((GVAR(animationControls) select 1) select _forEachIndex) select 1);
        };
    } forEach (GVAR(animationControls) select 0);
};

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
