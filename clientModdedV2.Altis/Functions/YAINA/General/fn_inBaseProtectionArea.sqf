/*
Function: YAINA_fnc_inBaseProtectionArea

Description:
	Returns true if the given player or object is inside the base's protection area,
	false otherwise.

Parameters:
	_obj - The object or player we want to check for

Return Values:
	true, if _obj is inside the base protection, false otherwise

Examples:
    Nothing to see here

Author:
	Martin
*/

#include "defines.h"

params ["_obj"];

_ret = false;

{
  if (_obj inArea _x) exitWith { _ret = true };
  nil
} count BASE_PROTECTION_AREAS;

_ret;