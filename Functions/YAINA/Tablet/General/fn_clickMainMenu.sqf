/*
	author: Martin
	description:
	    Handles the main menu clicks (P1 - P3)
	returns: nothing
*/

#include "..\defines.h"

disableSerialization;

params ["_button"];
private ["_buttons", "_text", "_page"];

private _tablet = ctrlParent _button;

// change the control color of this button to active the others to inactive
_buttons = [11, 12, 13];
_text    = [21, 22, 23];
_page    = nil;

for "_i" from 0 to ((count _buttons) - 1) step 1 do {

  // default state color/active
  _bc = [0.7,0.7,0.7,1];
  _ba = [1,1,1,1];

  // default text state
  _bt = [0.8, 0.8, 0.8, 1];

  _b = _tablet displayCtrl (_buttons select _i);
  _t = _tablet displayCtrl (_text select _i);

  if (_b isEqualTo _button) then {
    _bc = [1,1,1,1];
    _ba = [1,1,1,1];
    _bt = [1,1,1,1];
    _page = _i;
  };

  _b ctrlSetTextColor _bc;
  _b ctrlSetActiveColor _ba;
  _t ctrlSetTextColor _bt;

} forEach _buttons;

// Now switch the the child dialog
([
    [IDC_PAGE_REQUESTS],
    [IDC_PAGE_REWARDS],
    [IDC_PAGE_MESSAGE]
 ] select _page) call FNC(displayPage);