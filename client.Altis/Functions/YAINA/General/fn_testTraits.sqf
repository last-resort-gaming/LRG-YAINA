/*
Function: YAINA_fnc_testTraits

Description:
	Checks if the local player has access to the given trait(s).
    Returns true if that is the case, false otherwise.

Parameters:
	_this - A trait or an array of traits which we want to check against

Return Values:
	true if local player has these trait(s) set, false otherwise

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

// handle the backwards compat
private _traits = [];
private _unit = player;

// Handle backwards compat
if (typeName _this isEqualTo "ARRAY") then {
    // new [[TRAITS], UNIT]
    if ((typeName (_this select 0)) isEqualTo "ARRAY") then {
        _traits = _this select 0;
        _unit = [player, _this select 1] select (count _this > 1);
    } else {
        // existing [TRAIT, TRAIT, TRAIT]
        _traits = _this;
    }
} else {
    // existing "TRAIT" call
    _traits = [_this];
};

// We always check for "ALL" master trait
_traits pushBack "all";

// Duplicate to avoid appending to the players varaible every, single, query
private _pv  = (_unit getVariable [QYVAR(TRAITS), []]) + (_unit getVariable [QYVAR(ADMIN_TRAITS), []]);

!({ !(_pv find (toLower _x) isEqualTo -1); } count _traits isEqualTo 0);
