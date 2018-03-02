/*
	author: Martin
	description: none
	returns: nothing
*/

#include "defines.h"

params ["_obj"];

_ret = false;

{
  if (_obj inArea _x) exitWith { _ret = true };
  nil
} count BASE_PROTECTION_AREAS;

_ret;