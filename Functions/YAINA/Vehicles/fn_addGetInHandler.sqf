/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_veh", "_code", ["_codeArgs", []]];

private _v = _veh getVariable QVAR(getIn);

if (isNil "_v") then {
    _v = [];
};

_v pushBack [_code, _codeArgs];
_veh setVariable [QVAR(getIn), _v, true];