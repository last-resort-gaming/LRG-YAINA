/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

// UI updates...
disableSerialization;

// Broadcast Order in Progress
GVAR(orderRewardInProgress) = true;
GVAR(orderRewardInProgressLocal) = true;
publicVariable QVAR(orderRewardInProgress);

// We got an order...find what's selected
private _tablet = (findDisplay IDD_TABLET); if(_tablet isEqualTo displayNull) exitWith {};
private _page   = _tablet displayCtrl IDC_PAGE_REWARDS;
private _lb     = _page controlsGroupCtrl 1500;
private _class  = _lb lbData (lbCurSel _lb);

// Get price + build time from rewards publicVariable
GVAR(rewards) apply { _x select { _x select 0 isEqualTo _class; }; } select { !(_x isEqualTo []) } select 0 select 0
    params ["_class2", "_price", "_buildTime", ["_initCode", {}]];

// We immediately remove the credits to work with multiple users, and on cancel, add it to balance
[-_price, format["%1 ordered", _class]] remoteExecCall [QYFNC(addRewardPoints), 2];

// Hide the cancel button, set the scroll bar width to 0.000001 and update until complete
{ (_page controlsGroupCtrl _x) ctrlShow true; } forEach [
    1301,
    1302,
    1303,
    1601
];

// Disable the local ORDER Button (publicVar will cover remotes)
(_page controlsGroupCtrl 1600) ctrlShow false;

// Set teh width of 1301
private _bar   = _page controlsGroupCtrl 1301;
private _frame = _page controlsGroupCtrl 1302;
private _text  = _page controlsGroupCtrl 1303;

private _r = ctrlPosition _bar;
_r set [2, 0.000001];
_bar ctrlSetPosition _r;
_bar ctrlCommit 0;

// Now update teh width to that of the frame, and expand it
_r set [2, (ctrlPosition _frame) select 2 - 2 * pixelW];

_bar ctrlSetPosition _r;
_bar ctrlCommit _buildTime;

// Let folks know...
[player, format["Reward: %1 has been requested, ETA: %2", getText (configFile >> "CfgVehicles" >> _class >> "displayName"), _buildTime call YFNC(formatDuration)]] remoteExec ["sideChat"];

// Trigger the progress updater / complete trigger
_pfh = {
    params ["_args", "_pfhID"];
    _args params ["_bar", "_targetWidth", "_textCtrl", "_completeCode", "_completeCodeArgs"];

    // If player closes the dialog, cancel it...
    if ((findDisplay IDD_TABLET) isEqualTo displayNull) then {
        call FNC(clickCancelReward);
    } else {
        if !(ctrlCommitted _bar) then {
            _textCtrl ctrlSetText format ["building... %1%2", floor(100 * (ctrlPosition _bar select 2) / _targetWidth), "%"];
        } else {
            [_pfhId] call CBAP_fnc_removePerFrameHandler;
            _completeCodeArgs call _completeCode;
        };
    };
};

// Start it going
_pfhID = [_pfh, 1, [_bar, _r select 2, _text, {
    params ["_class"];

    [player, _class] remoteExecCall [QFNC(provisionReward), 2];

    // And re-enable everything
    GVAR(orderInProgress) = nil;
    call FNC(clickCancelReward);

}, [_class, _initCode]]] call CBAP_fnc_addPerFrameHandler;

// CancelCode
_cancelCode = {
    params ["_class", "_price"];
    [_price, format["cancelled reward: %1", _class]] remoteExecCall [QYFNC(addRewardPoints),2];
};

GVAR(orderInProgress) = [_pfhID, _cancelCode, [_class, _price]];
