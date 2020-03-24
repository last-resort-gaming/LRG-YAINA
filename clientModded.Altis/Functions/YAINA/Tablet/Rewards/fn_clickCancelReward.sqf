/*
Function: YAINA_TABLET_fnc_clickCancelReward

Description:
	Runs when a player requests cancellation of a reward. Stops
    the vehicle from spawning, refunds the credits and does some 
    messaging stuff.

Parameters:
	None

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h"

// UI updates...
disableSerialization;

// If we have a PFH in progress, cancel it, and action the cancel code
_pfhIds = GVAR(orderInProgress);
if !(isNil "_pfhIds") then {
    _pfhIds params ["_pfhID", "_cancelCode", "_cancelCodeArgs"];
    [_pfhID] call CBAP_fnc_removePerFrameHandler;

    [[west, "HQ"], format["Reward: %1 has been cancelled", getText (configFile >> "CfgVehicles" >> (_cancelCodeArgs select 0) >> "displayName")]] remoteExec ["sideChat"];

    _cancelCodeArgs call _cancelCode;
    GVAR(orderInProgress) = nil;
};

private _tablet = (findDisplay IDD_TABLET); if(_tablet isEqualTo displayNull) exitWith {};
private _page   = _tablet displayCtrl IDC_PAGE_REWARDS;

// We hide the progress bar, and cancel button, and ensure the ORDER button is visible
{ (_page controlsGroupCtrl _x) ctrlShow false; } forEach [
    1301,
    1302,
    1303,
    1601
];

if GVAR(orderRewardInProgressLocal) then {
    GVAR(orderRewardInProgress) = false;
    GVAR(orderRewardInProgressLocal) = false;
    publicVariable QVAR(orderRewardInProgress);
};

(_page controlsGroupCtrl 1600) ctrlShow true;

// Refresh to be sure if it was clicked from object
[{ [true] call FNC(refreshRewardsPage) }, [], 0.5] call CBAP_fnc_waitAndExecute;

