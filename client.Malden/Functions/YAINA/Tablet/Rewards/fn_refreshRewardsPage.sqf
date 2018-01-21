/*
	author: Martin
	description: none
	returns: nothing
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
