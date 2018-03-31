/*
	author: Martin
	description: none
	returns: nothing
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