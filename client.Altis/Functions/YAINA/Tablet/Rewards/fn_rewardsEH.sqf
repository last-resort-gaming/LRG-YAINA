/*
Function: YAINA_TABLET_fnc_rewardsEH

Description:
	Adds a public variable event handler to make the rewards system
    unavailable to other players while we are already processing an
    order. Added during postInit.

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

// Public Variable Handlers
QVAR(orderRewardInProgress) addPublicVariableEventHandler  {
    private _tablet = findDisplay IDD_TABLET; if(_tablet isEqualTo displayNull) exitWith {};

    // We re-select the currently selected item, to check area is clear etc.
    // and to ensure the order button state
    if (ctrlVisible IDC_PAGE_REWARDS) then {
        [] call FNC(refreshRewardsPage);
    };

};