/*
	author: Martin
	description: none
	returns: nothing
*/


#include "..\defines.h"

params ["_owner", "_caller", "_argStr"];

_msg = "I am a server message";
_msg remoteExecCall ["systemChat"];

_msg