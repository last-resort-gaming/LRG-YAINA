/*
Function: YAINA_TABLET_fnc_refreshMessagePage

Description:
	Refreshes the message page. Currently this only show Coming Soon, 
	but you can always dream, right?

Parameters:
	_message - The message to show on the page

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "..\defines.h";

params [["_message", "<br/><br/>Coming Soon...<br/><br/>This tab is coming soon, please bare with us whilst we add functionality"]];
private ["_tablet", "_st"];

disableSerialization;

// Find Tablet
_tablet = findDisplay IDD_TABLET;
if(_tablet isEqualTo displayNull) exitWith {};

// Get the Structured Text Field
_st = _tablet displayCtrl IDC_PAGE_MESSAGE controlsGroupCtrl 1500;
_st ctrlSetStructuredText parseText _message;