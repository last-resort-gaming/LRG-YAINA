/*
	author: Martin
	description: none
	returns: nothing
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
private _pv = (_unit getVariable [QYVAR(TRAITS), []]) + [];

// Append Server Traits
if !(isNil QYVAR(GLOBAL_TRAITS)) then {
    _pv append YVAR(GLOBAL_TRAITS);
};

!({ !(_pv find (toLower _x) isEqualTo -1); } count _traits isEqualTo 0);
