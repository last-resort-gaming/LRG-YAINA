/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

// Set the function to run when all the ropes attaching to
// item completes

params ["_item", "_func"];


_v = _item getVariable QVAR(rddh);
if (isNil "_v") then {
    _v = [_func];
} else {
    _v pushBack _func;
};

_item setVariable [QVAR(rddh), _v, true];