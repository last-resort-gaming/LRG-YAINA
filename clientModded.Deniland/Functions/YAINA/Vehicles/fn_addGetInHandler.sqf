/*
Function: YAINA_VEH_fnc_addGetInHandler

Description:
	Add a getIn handler to the given vehicle. The given code will be 
	executed with the passed arguments whenever someone gets in 
	the vehicle.

Parameters:
	_veh - The vehicle to which we want to add the event handler
	_code - The code executed whenever the event is triggered
	_codeArgs - The arguments passed to the executed code

Return Values:
	None

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_veh", "_code", ["_codeArgs", []]];

private _v = _veh getVariable [QVAR(getIn), []];
_v pushBack [_code, _codeArgs];
_veh setVariable [QVAR(getIn), _v, true];