/*
	author: Martin
	description: none
	returns: nothing
*/

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

private _pv = _unit getVariable ["YAINA_TRAITS", []];
!({ !(_pv find (toLower _x) isEqualTo -1); } count _traits isEqualTo 0);