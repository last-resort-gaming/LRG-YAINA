/*
Function: YAINA_TABLET_fnc_refreshRewardsPage

Description:
	This refreshes the rewards page, resetting it back to what it was
	when we started out.

Parameters:
	_internal - Unused variable

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

// Default we select helis
#include "..\defines.h"

params [["_internal", false]];

// If we have a selection, re-select, else simulate a click of 30
private _lastSelection = GVAR(lastRewardSelection);
if !(isNil "_lastSelection") then {
    (_lastSelection + [_internal]) call FNC(selectionChangedRewards);
} else {
    // Simple, we just simulate a click of 30
    30 call FNC(clickRewardsButton);
};
