/*
	author: Martin
	description: none
	returns: nothing
*/

#include "..\defines.h"

// Control Group IDC
params ["_page", ["_pageArgs", []]];

disableSerialization;

// Only go and show the page we want
{ctrlShow [_x,false];} count IDC_PAGES;

// Validate Page Permissions for now here
if (_page isEqualTo IDC_PAGE_REWARDS && { !( ['HQ', 'hq-tablet'] call YFNC(testTraits) ) } ) then {
    _page = IDC_PAGE_MESSAGE;
    _pageArgs = ["<br/><br/>You're Not HQ...<br/><br/>Only HQ is able to request assets"];
};

ctrlShow [_page, true];

// We need to refresh the page, so call that here
if (_page isEqualTo IDC_PAGE_REWARDS) exitWith { _pageArgs call FNC(refreshRewardsPage); };
if (_page isEqualTo IDC_PAGE_AMMOBOX) exitWith { _pageArgs call FNC(refreshLoadoutPage); };
if (_page isEqualTo IDC_PAGE_MESSAGE) exitWith { _pageArgs call FNC(refreshMessagePage); };
