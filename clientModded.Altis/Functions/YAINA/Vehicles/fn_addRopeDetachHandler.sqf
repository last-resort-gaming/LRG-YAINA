/*
Function: YAINA_VEH_fnc_addRopeDetachHandler

Description:
	Executes passed function once all ropes attached to the given 
	object have been detached.

Parameters:
	_item - The object to which we want to add the event handler
	_func - The function which we want to execute

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
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