/*
	author: Martin
	description: none
	returns: nothing
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
