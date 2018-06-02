/*
Function: YAINA_fnc_hintC

Description
	Show a cadet hint (hintC) on the machine that called this function.
    We handle confirmation of the hint with an EH, to stop a second, normal
    hint from appearing at the top of the screen.

Parameters:
	_text - The message that is supposed to be displayed

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_text"];

hintC _text;

// And to stop it showing up on the right side as soon as we OK
// the message for unload on 57, blat it from 0

YVAR(hintC_EH) = findDisplay 57 displayAddEventHandler ["unload", {
    0 = _this spawn {
        _this select 0 displayRemoveEventHandler ["unload", YVAR(hintC_EH)];
        hintSilent "";
    };
}];
